import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader
from torcheval.metrics import MulticlassPrecision, MulticlassRecall, MulticlassAccuracy, MulticlassF1Score
from tqdm import tqdm
from typing import Tuple, List, Any

from dataset_11 import get_dataset, load_data, load_clean_data
import pdb


def fixed_fwd_op(
        model: nn.Module,
        data_loader: DataLoader,
        device: str = 'cuda',
        num_class: int = 2,
        overflow = False
) -> List[Tuple[float, Any, Any, Any, Any]]:
    """ Perform evaluation.

    Args:
        model: Model instance.
        data_loader: Data loader in PyTorch.
        device: Device name/number for usage. The desired device of the parameters
                and buffers in this module.

    Returns:
        Task metrics
    """
    model = model.to(device)

    model.eval()
    model.fullfix_model()
    task1_outputs = []

    with torch.no_grad():
        pbar = tqdm(enumerate(data_loader), total=len(data_loader), desc=f"Evaluation")
        for batch_idx, (inputs, labels) in pbar:
            inputs = inputs.to(device)
            outputs1 = model.fixed_fwd(inputs).cpu()

            task1_outputs.append((outputs1, labels))

    task_metrics = []

    for task_outputs, n_classes in zip([task1_outputs], [num_class]):        
        total_loss = 0.0
        total_batches = 0

        prec_metric = MulticlassPrecision(average=None, num_classes=n_classes)
        recall_metric = MulticlassRecall(average=None, num_classes=n_classes)
        f1_metric = MulticlassF1Score(average=None, num_classes=n_classes)
        accuracy_metric = MulticlassAccuracy(num_classes=n_classes)

        for outputs, labels in task_outputs:
            loss = F.cross_entropy(outputs, labels)
            total_loss += loss.item()
            total_batches += 1

            prec_metric.update(torch.argmax(outputs, dim=1), torch.argmax(labels, dim=1))
            recall_metric.update(torch.argmax(outputs, dim=1), torch.argmax(labels, dim=1))
            f1_metric.update(torch.argmax(outputs, dim=1), torch.argmax(labels, dim=1))
            accuracy_metric.update(torch.argmax(outputs, dim=1), torch.argmax(labels, dim=1))

        avg_loss = 0
        avg_precision = prec_metric.compute().mean()
        avg_recall = recall_metric.compute().mean()
        avg_f1 = f1_metric.compute().mean()
        accuracy = accuracy_metric.compute().detach().cpu().numpy()

        task_metrics.append([avg_loss, avg_precision, avg_recall, avg_f1, accuracy.item()])
        print("accuracy: ", accuracy)

    return task_metrics





def fix_train_op(
        model: nn.Module,
        batch_size: int = 512,
        n_epochs: int = 16,
        device: str = 'cuda',
        task_weights: Tuple[int, int] = (1, 1),
        use_wandb: bool = False,
        overflow: bool = False
):
    """ Perform training iteration in PyTorch.

    Args:
        model: Model instance.
        batch_size: Batch size.
        n_epochs: Epochs.
        device: Device name/number for usage. The desired device of the parameters
                and buffers in this module.
        task_weights: Assign weights of loss calculation for multi-class classification.
        use_wandb: Enable wandb to record training log.

    Returns:

    """
    device = device


    # Load raw data
    train_data_rows, val_data_rows, test_data_rows = load_data()
    

    # Prepare dataset from subclass of torch.utils.data.Dataset
    train_dataset = get_dataset(train_data_rows)
    val_dataset = get_dataset(val_data_rows)

    # Create DataLoader to load the data in batches
    train_data_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_data_loader = DataLoader(val_dataset, batch_size=102400, shuffle=False)

    # Move model parameters to specified devices
    model = model.to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=0.001, weight_decay=0.0001)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, 'min', patience=10)

    # Initialize accuracy to save best model
    best_accuracy = 0.0
    avg_loss = 0.0

    # Training loop by epoch
    for epoch in range(n_epochs):
        # Store
        running_loss = 0.0

        # Initialize progress bar
        pbar = tqdm(enumerate(train_data_loader), total=len(train_data_loader), desc=f"Epoch {epoch + 1}, Loss: 0.000")
        optimizer.zero_grad()

        # Loop training dataset
        for batch_idx, (inputs, labels_task3, labels_task2, labels_task3) in pbar:
            # model.fixed_model(no_bias=no_bias)
            model.train()
            inputs = inputs.to(device)
            outputs_task1 = model.fixed_fwd(inputs)
            loss_task1 = F.cross_entropy(outputs_task1, labels_task3.to(device))

            # Backpropagation and update model parameters
            loss_task1.backward()
            optimizer.step()
            optimizer.zero_grad()
            
            running_loss += loss_task1.item()
            avg_loss = running_loss / (batch_idx + 1)

            # Update the description of progress bar with the average loss
            pbar.set_description(f"Epoch {epoch + 1}, Loss: {avg_loss:.4f}")
            pbar.set_postfix(loss=avg_loss)

        # Evaluation after each epoch
        metrics = fixed_fwd_op(model, val_data_loader)

        # Log metrics
        task_accuracy = []
        for task_i, m in enumerate(metrics):
            print(f"Task {task_i + 1} - Validation Loss: {m[0]:.4f}, "
                  f"Precision: {m[1]:.4f}, Recall: {m[2]:.4f}, F1: {m[3]:.4f} , Accuracy: {m[4]:.4f}")

            # Record task accuracy
            task_accuracy.append(m[4])

        # Save best model according to the accuracy of 'application'
        target_accuracy = task_accuracy[0]
        if target_accuracy >= best_accuracy:
            torch.save(model.state_dict(), './fix8_weights.pt')
            best_accuracy = target_accuracy

        # Update scheduler to modify learning rate
        scheduler.step(avg_loss)

    return model