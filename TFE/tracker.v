/*  
    This module is used for tracking a direction within a flow.
    
    This module will track and keep state information for master dir-
    ection, slave direction and global flow. 
    It is defined that the direction of first packet is the master d-
    irection. 

 */


module Tracker (
    input   wire                                clk,
    input   wire                                rst_n,

    input   wire    [31:0]                      hash, // hash value of packet
    input   wire    [31:0]                      r_hash, // hash value of packet with reverse ip tuple
    input   wire                                hash_v,

    // feature used for 1-stage extracting
    input   wire    [15:0]                      pkt_arvt, // initial time be 16-bit, unit is us
    input   wire    [15:0]                      i_pkt_size, // TCP uses 16-bit to doc pkt_size

    output  wire                                hit_w,
    output  wire                                rd_main_cache,
    output  wire    [11:0]                      rd_main_cache_addr_w,

    // threshold and 1-stage feature output to buffer/alu
    input   wire    [7:0]                        threshold,
    // used by vector feature
    output  wire    [7:0]                       o_pkt_size,
    output  wire    [7:0]                       o_pkt_arit,
    output  wire    [7:0]                       o_n_pkt,
    output  wire                                o_size_arit_v,
    output  wire    [11:0]                      o_hash,
    output  wire    [11:0]                      o_r_hash,
    // flow feature controlled by threshold
    output  wire    [7:0]                       o_flow_durt,
    output  wire    [7:0]                       o_flow_size,

    // free addr signal
    input   wire                                free_addr_v,
    input   wire    [11:0]                      free_addr,
    input   wire    [11:0]                      free_r_addr,

    output  wire                                o_reach_thrh
    
);


// rd state ram related signal
wire    [49:0]                                  master_ram_rdata;
wire    [49:0]                                  slave_ram_rdata;
reg                                             tracked_state_v;
reg                                             tracked_state_v_r0;
reg                                             tracked_state_v_r1;
reg                                             tracked_state_v_r2;
reg                                             tracked_state_v_r3;

// hit or not related signal
reg                                             hash_hit_master;
reg                                             hash_hit_slave;

// caching related signal
reg                                             master;
reg     [31:0]                                  hash_r0;
reg     [31:0]                                  hash_r1;
reg     [31:0]                                  hash_r2;
reg     [31:0]                                  hash_r3;
reg     [31:0]                                  r_hash_r0;
reg     [31:0]                                  r_hash_r1;
reg     [31:0]                                  r_hash_r2;
reg     [31:0]                                  r_hash_r3;


// wr state ram related signal
reg     [31:0]                                  slave_ram_waddr;
reg     [31:0]                                  master_ram_waddr;
reg                                             wr_ram_master;
reg                                             wr_ram_slave;
reg     [49:0]                                  master_ram_wdata;
reg     [49:0]                                  slave_ram_wdata;

// 1-stage feature extracting related signal
wire    [7:0]                                    first_pkt_arvt;
wire    [7:0]                                    last_pkt_arvt;
wire    [7:0]                                    flow_durt;
wire    [7:0]                                    flow_size;
assign        first_pkt_arvt               =        master_ram_rdata_r1[49:42];
assign        last_pkt_arvt                =        master_ram_rdata_r1[41:34];
assign        flow_durt                    =        master_ram_rdata_r1[33:26];
assign        flow_size                    =        master_ram_rdata_r1[25:18];
assign        pkt_arit                     =        master_ram_rdata_r1[9:2];

wire    [7:0]                                    slave_first_pkt_arvt;
wire    [7:0]                                    slave_last_pkt_arvt;
wire    [7:0]                                    slave_flow_durt;
wire    [7:0]                                    slave_flow_size;
assign        slave_first_pkt_arvt        =        slave_ram_rdata_r1[49:42];
assign        slave_last_pkt_arvt         =        slave_ram_rdata_r1[41:34];
assign        slave_flow_durt             =        slave_ram_rdata_r1[33:26];
assign        slave_flow_size             =        slave_ram_rdata_r1[25:18];
assign        slave_pkt_arit              =        slave_ram_rdata_r1[9:2];




// read main feature cache and transfer hit information
reg                                                hit;
reg                                                being_judge_hit;
reg     [11:0]                                     rd_main_cache_addr;
reg     [11:0]                                     o_r_hash_r;
assign        hit_w                          =        hit;
assign        rd_main_cache                  =        being_judge_hit;
assign        rd_main_cache_addr_w           =        rd_main_cache_addr;
assign        o_r_hash                       =        o_r_hash_r;


always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_main_cache_addr                  <=      12'd0;
        o_r_hash_r                          <=      12'd0;
    end
    else begin
        if(tracked_state_v_r1) begin
            case({hash_hit_master, hash_hit_slave})
            2'b00: begin
                rd_main_cache_addr              <=       hash_r2[11:0];
                o_r_hash_r                      <=       r_hash_r2[11:0];
            end
            2'b01: begin
                rd_main_cache_addr              <=       r_hash_r2[11:0];
                o_r_hash_r                      <=       hash_r2[11:0];
            end
            2'b10: begin
                rd_main_cache_addr              <=       hash_r2[11:0];
                o_r_hash_r                      <=       r_hash_r2[11:0];
            end
            endcase
        end
    end
end



// 1-stage feature for output
reg        [7:0]                                    o_pkt_size_r;
reg        [7:0]                                    o_pkt_arit_r;
reg        [7:0]                                    o_n_pkt_r;
reg                                                 o_size_arit_v_r;
reg        [7:0]                                    o_flow_durt_r;
reg        [7:0]                                    o_flow_size_r;

assign        o_pkt_size                    =        pkt_size_r3;
assign        o_pkt_arit                    =        wpkt_arit;
assign        o_n_pkt                       =        wn_pkt;
assign        o_size_arit_v                 =        o_size_arit_v_r;
assign        o_hash                        =        rd_main_cache_addr;
assign        o_flow_durt                   =        wflow_durt;
assign        o_flow_size                   =        wflow_size;


// n_pkt feature process
reg     [7:0]                                       slave_n_pkt;
reg     [7:0]                                       n_pkt;
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        slave_n_pkt                     <=          'd0;
        n_pkt                           <=          'd0;
    end
    else begin
        slave_n_pkt                     <=          slave_ram_rdata_r0[17:10];
        n_pkt                           <=          master_ram_rdata_r0[17:10];
    end
end







// threshold control signal
reg                                                o_reach_thrh_r;
assign        o_reach_thrh                =        o_reach_thrh_r;
reg        [7:0]                                    threshold_r;
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        threshold_r                        <=        'd0;
    end
    else begin
        threshold_r                        <=        threshold;
    end
end

reg                                                occupied_flag;
reg                                                reach_thrh_flag;



// DFT signal
wire    [7:0]                                    wfirst_pkt_arvt;
wire    [7:0]                                    wlast_pkt_arvt;
wire    [7:0]                                    wflow_durt;
wire    [7:0]                                    wflow_size;
wire    [7:0]                                    wn_pkt;
wire    [7:0]                                    wpkt_arit;
assign        wfirst_pkt_arvt                =        master_ram_wdata[49:42];
assign        wlast_pkt_arvt                 =        master_ram_wdata[41:34];
assign        wflow_durt                     =        master_ram_wdata[33:26];
assign        wflow_size                     =        master_ram_wdata[25:18];
assign        wn_pkt                         =        master_ram_wdata[17:10];
assign        wpkt_arit                      =        master_ram_wdata[9:2];


always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hash_r0                            <=        32'd0;
        hash_r1                            <=        32'd0;
        hash_r2                            <=        32'd0;
        hash_r3                            <=        32'd0;
        r_hash_r0                          <=        32'd0;
        r_hash_r1                          <=        32'd0;
        r_hash_r2                          <=        32'd0;
    end
    else begin
        hash_r0                            <=        hash;
        hash_r1                            <=        hash_r0;
        hash_r2                            <=        hash_r1;
        hash_r3                            <=        hash_r2;
        r_hash_r0                          <=        r_hash;
        r_hash_r1                          <=        r_hash_r0;
        r_hash_r2                          <=        r_hash_r1;
        r_hash_r3                          <=        r_hash_r2;
    end
end



// caching pkt_size and pkt_arit
reg     [15:0]                                  pkt_arvt_r0;
reg     [7:0]                                   pkt_arvt_r1;
reg     [7:0]                                   pkt_arvt_r2;
reg     [7:0]                                   pkt_arvt_r3;
reg     [15:0]                                  pkt_size_r0;
reg     [7:0]                                   pkt_size_r1;
reg     [7:0]                                   pkt_size_r2;
reg     [7:0]                                   pkt_size_r3;
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        tracked_state_v_r0                <=        1'd0;
        tracked_state_v_r1                <=        1'd0;
        tracked_state_v_r2                <=        1'd0;
        tracked_state_v_r3                <=        1'd0;

        pkt_arvt_r0                       <=        16'd0;
        pkt_arvt_r1                       <=        8'd0;
        pkt_arvt_r2                       <=        8'd0;
        pkt_arvt_r3                       <=        8'd0;

        pkt_size_r0                       <=        16'd0;
        pkt_size_r1                       <=        8'd0;
        pkt_size_r2                       <=        8'd0;
        pkt_size_r3                       <=        8'd0;
    end
    else begin
        tracked_state_v_r0                <=        tracked_state_v;
        tracked_state_v_r1                <=        tracked_state_v_r0;
        tracked_state_v_r2                <=        tracked_state_v_r1;
        tracked_state_v_r3                <=        tracked_state_v_r2;

        pkt_arvt_r0                        <=        pkt_arvt;
        pkt_arvt_r1                        <=        pkt_arvt_r0[7:0];
        pkt_arvt_r2                        <=        pkt_arvt_r1;
        pkt_arvt_r3                        <=        pkt_arvt_r2;

        pkt_size_r0                        <=        i_pkt_size;
        pkt_size_r1                        <=        pkt_size_r0[10:3];
        pkt_size_r2                        <=        pkt_size_r1;
        pkt_size_r3                        <=        pkt_size_r2;
    end
end





// read track info
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        tracked_state_v                 <=      1'd0;
    end
    else begin
        if(hash_v) begin
            tracked_state_v             <=      1'b1;
        end
        else begin
            tracked_state_v             <=      1'b0;
        end
    end
end


// judging master hit and slave hit
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hash_hit_master                     <=          1'd0;
        hash_hit_slave                      <=          1'd0;
    end
    else begin
        hash_hit_master                     <=          master_ram_rdata_r0[0] & tracked_state_v_r0;
        hash_hit_slave                      <=          slave_ram_rdata_r0[0] & tracked_state_v_r0;
    end
end


wire            hash_hit_master_tb;
wire            hash_hit_slave_tb;
wire            hash_hit_master_r_tb;
wire            hash_hit_slave_r_tb;
wire            slave_cond_tb;
wire            master_cond_tb;
wire    [7:0]   slave_wnpkt_tb;
assign          hash_hit_master_tb          =       master_ram_rdata[0];
assign          hash_hit_slave_tb           =       slave_ram_rdata[0];
assign          hash_hit_master_r_tb        =       master_ram_rdata_r0[0];
assign          hash_hit_slave_r_tb         =       slave_ram_rdata_r0[0];
assign          slave_cond_tb               =       slave_ram_rdata_r1[1];
assign          master_cond_tb              =       master_ram_rdata_r1[1];
assign          slave_wnpkt_tb              =       slave_ram_wdata[17:10];


reg     [7:0]                               master_wnpkt_r_tb;
reg     [7:0]                               slave_wnpkt_r_tb;





/*     
    Updating hit flag in the state ram: 
    1. If both master ram and slave ram are non-hit, then
    it is a new flow, using hash to flag master ram and u-
    sing rhash to flag slave ram.
    2. If a packet from master direction comes, it will h-
    it master ram and non-hit slave ram.
    3. If a packet from slave direction comes, it will non-
    hit master ram and hit slave ram.

*/
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_ram_master                       <=        1'b0;
        wr_ram_slave                        <=        1'b0;
        master_ram_wdata                    <=        50'b0;
        slave_ram_wdata                     <=        50'b0;
        slave_ram_waddr                     <=        32'b0;
        master_ram_waddr                    <=        32'b0;
        being_judge_hit                     <=        1'd0;
        hit                                 <=        1'd0;
        occupied_flag                       <=        1'd0;
        reach_thrh_flag                     <=        1'd0;
        master_wnpkt_r_tb                   <=        8'd0;
        slave_wnpkt_r_tb                    <=        8'd0;

        wr_free_state_ram_master_g0         <=        1'd0;
        wr_free_state_ram_slave_g0          <=        1'd0;
    end
    else begin
        // after getting information
        if(tracked_state_v_r1) begin
            being_judge_hit             <=        1'd1;
            
            case({hash_hit_master, hash_hit_slave})
            2'b00: begin // a new flow
                // wr free state ram
                wr_free_state_ram_master_g0    <=      1'b0;
                wr_free_state_ram_slave_g0     <=      1'b0;
                wr_free_state_ram_master_g1    <=      1'b0;
                wr_free_state_ram_slave_g1     <=      1'b0;

                hit                     <=        1'd0;

                // flag both master and slave ram
                wr_ram_master           <=        1'b1;
                wr_ram_slave            <=        1'b1;

                // master ram and slave ram use different addr
                master_ram_waddr        <=        hash_r2;
                slave_ram_waddr         <=        r_hash_r2;

                // set initial val for first pkt, and same for slave ram to keep data consisteny
                //                              1st_pkt_arvt, last_pkt_arvt, flow_durt, flow_size,     n_pkt, pkt_arit, flag
                master_ram_wdata        <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};
                slave_ram_wdata         <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};

                // 1-stage and vector feature output
                o_pkt_size_r            <=        pkt_size_r2;
                o_pkt_arit_r            <=        'd0;
                o_n_pkt_r               <=        'd1;
                o_size_arit_v_r         <=        'd1;
                o_flow_durt_r           <=        'd0;
                o_flow_size_r           <=        pkt_size_r2;
                o_reach_thrh_r          <=        'd0;

                // tb signal
                master_wnpkt_r_tb       <=          8'd1;
                slave_wnpkt_r_tb        <=          8'd1;
            end

            2'b01: begin // a slave pkt
                // this bit is used for judging reach_thrh
                if(slave_ram_rdata_r1[1] == 'd0) begin // not reach thrh
                    // wr free state ram
                    wr_free_state_ram_master_g0    <=      1'b0;
                    wr_free_state_ram_slave_g0     <=      1'b0;
                    
                    hit                       <=        1'd1;

                    wr_ram_slave              <=        1'b1;
                    wr_ram_master             <=        1'b1;

                    // update master ram with slave direction for flow feature extratcing
                    master_ram_waddr           <=        r_hash_r2;
                    slave_ram_waddr            <=        hash_r2;
                    
                    // if reaching threshold, set flag
                    if (slave_n_pkt+1'b1 >= threshold_r) begin
                        o_reach_thrh_r        <=        'd1;
                        master_ram_wdata      <=        {slave_first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-slave_first_pkt_arvt, slave_flow_size+pkt_size_r2, slave_n_pkt+1'b1, pkt_arvt_r2-slave_last_pkt_arvt,  2'b11};
                        // using consisteny data in slave ram
                        slave_ram_wdata       <=        {slave_first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-slave_first_pkt_arvt, slave_flow_size+pkt_size_r2, slave_n_pkt+1'b1, pkt_arvt_r2-slave_last_pkt_arvt,  2'b11};
                        
                        // tb signal
                        master_wnpkt_r_tb       <=          slave_n_pkt+1'b1;
                        slave_wnpkt_r_tb        <=          slave_n_pkt+1'b1;
                    end
                    
                    else begin
                        // using consisteny data in slave ram
                        master_ram_wdata      <=        {slave_first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-slave_first_pkt_arvt, slave_flow_size+pkt_size_r2, slave_n_pkt+1'b1, pkt_arvt_r2-slave_last_pkt_arvt,  2'b01};
                        slave_ram_wdata       <=        {slave_first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-slave_first_pkt_arvt, slave_flow_size+pkt_size_r2, slave_n_pkt+1'b1, pkt_arvt_r2-slave_last_pkt_arvt,  2'b01};
                        o_reach_thrh_r        <=        'd0;

                        // tb signal
                        master_wnpkt_r_tb       <=          slave_n_pkt+1'b1;
                        slave_wnpkt_r_tb        <=          slave_n_pkt+1'b1;
                    end

                    // 1-stage and vector feature output
                    o_pkt_size_r            <=        pkt_size_r2;
                    o_pkt_arit_r            <=        pkt_arvt_r2-slave_last_pkt_arvt;
                    o_n_pkt_r               <=        slave_n_pkt+1'b1;
                    o_size_arit_v_r         <=        'd1;
                    o_flow_durt_r           <=        pkt_arvt_r2-slave_first_pkt_arvt;
                    o_flow_size_r           <=        slave_flow_size+pkt_size_r2;
                end
                
                // flow that reach_thrh
                // if reach thrh:
                // 1. if this address is ready-to-be-free, then update as a brand new flow
                // 2. this address is in-flight, thus nothing needs to be done
                else begin
                    // free current addr and let new flow in
                    if (master_free_r1_g0 || master_free_r1_g1 ) begin
                        // wr free state ram
                        wr_free_state_ram_master_g0    <=      1'b1;
                        wr_free_state_ram_slave_g0     <=      1'b1;
                        wr_free_state_ram_master_g1    <=      1'b1;
                        wr_free_state_ram_slave_g1     <=      1'b1;

                        hit                         <=        1'd0;
                        // flag both master and slave ram
                        wr_ram_master               <=        1'b1;
                        wr_ram_slave                <=        1'b1;

                        // master ram and slave ram use different addr
                        master_ram_waddr            <=        hash_r2;
                        slave_ram_waddr             <=        r_hash_r2;

                        // set initial val for first pkt, and same for slave ram to keep data consisteny
                        //                                    1st_pkt_arvt, last_pkt_arvt, flow_durt, flow_size,     n_pkt, pkt_arit, flag
                        master_ram_wdata            <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};
                        slave_ram_wdata             <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};

                        // 1-stage and vector feature output
                        o_pkt_size_r                <=        pkt_size_r2;
                        o_pkt_arit_r                <=        'd0;
                        o_n_pkt_r                   <=        'd1;
                        o_size_arit_v_r             <=        'd1;
                        o_flow_durt_r               <=        'd0;
                        o_flow_size_r               <=        pkt_size_r2;
                        o_reach_thrh_r              <=        'd0;

                        // tb signal
                        master_wnpkt_r_tb           <=          8'd1;
                        slave_wnpkt_r_tb            <=          8'd1;
                    end
                    // an in-flight flow, need not free
                    else begin
                        wr_ram_master           <=        1'b0;
                        wr_ram_slave            <=        1'b0;
                        master_ram_wdata        <=        50'd0;
                        slave_ram_wdata         <=        50'd0;
                        slave_ram_waddr         <=        32'd0;
                        hit                     <=        1'd0;

                        // 1-stage and vector feature output
                        o_pkt_size_r            <=        'd0;
                        o_pkt_arit_r            <=        'd0;
                        o_n_pkt_r               <=        'd0;
                        o_size_arit_v_r         <=        'd0;
                        o_flow_durt_r           <=        'd0;
                        o_flow_size_r           <=        'd0;
                        o_reach_thrh_r          <=        'd0;

                        // free state signal
                        wr_free_state_ram_master_g0    <=      1'b0;
                        wr_free_state_ram_slave_g0     <=      1'b0;
                        wr_free_state_ram_master_g1    <=      1'b0;
                        wr_free_state_ram_slave_g1     <=      1'b0;

                        // tb signal
                        master_wnpkt_r_tb       <=          slave_n_pkt;
                        slave_wnpkt_r_tb        <=          slave_n_pkt;
                    end
                end
                
            end
            
            2'b10: begin // a master pkt
                // this bit is used for judging reach_thrh
                if(master_ram_rdata_r1[1] == 'd0) begin  // not reach thrh
                    hit                        <=        1'd1;

                    wr_ram_master              <=        1'b1;
                    wr_ram_slave               <=        1'b1;
                    
                    // update master ram for master direction, and same for slave ram to keep data consisteny
                    //                              1st_pkt_arvt,  last_pkt_arvt, flow_durt,                   flow_size,             n_pkt,      pkt_arit,                     flag
                    master_ram_waddr            <=        hash_r2;

                    slave_ram_waddr             <=        r_hash_r2;
                
                    // 1-stage and vector feature output
                    o_pkt_size_r               <=        pkt_size_r2;
                    o_pkt_arit_r               <=        pkt_arvt_r2-slave_last_pkt_arvt;
                    o_n_pkt_r                  <=        slave_n_pkt+1'b1;
                    o_size_arit_v_r            <=        'd1;
                    o_flow_durt_r              <=        pkt_arvt_r2-first_pkt_arvt;
                    o_flow_size_r              <=        flow_size+pkt_size_r2;
                    if (n_pkt+1'b1 >= threshold_r) begin
                        master_ram_wdata       <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b11};
                        slave_ram_wdata        <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b11};
                        o_reach_thrh_r         <=        'd1;
                        // tb signal
                        master_wnpkt_r_tb      <=          n_pkt+1'b1;
                        slave_wnpkt_r_tb       <=          n_pkt+1'b1;
                    end
                    else begin
                        master_ram_wdata       <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b01};
                        slave_ram_wdata        <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b01};
                        o_reach_thrh_r         <=        'd0;
                        // tb signal
                        master_wnpkt_r_tb      <=          n_pkt+1'b1;
                        slave_wnpkt_r_tb       <=          n_pkt+1'b1;
                    end
                end


                // flow that reach_thrh
                // if reach thrh:
                // 1. if this address is ready-to-be-free, then update as a brand new flow
                // 2. this address is in-flight, thus nothing needs to be done
                else begin
                    // free current addr and let new flow in
                    if(master_free_r1_g0 || master_free_r1_g1) begin
                        // wr free state ram
                        wr_free_state_ram_master_g0    <=      1'b1;
                        wr_free_state_ram_slave_g0     <=      1'b1;
                        wr_free_state_ram_master_g1    <=      1'b1;
                        wr_free_state_ram_slave_g1     <=      1'b1;

                        hit                         <=        1'd0;
                        // flag both master and slave ram
                        wr_ram_master               <=        1'b1;
                        wr_ram_slave                <=        1'b1;

                        // master ram and slave ram use different addr
                        master_ram_waddr            <=        hash_r2;
                        slave_ram_waddr             <=        r_hash_r2;

                        // set initial val for first pkt, and same for slave ram to keep data consisteny
                        //                                    1st_pkt_arvt, last_pkt_arvt, flow_durt, flow_size,     n_pkt, pkt_arit, flag
                        master_ram_wdata            <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};
                        slave_ram_wdata             <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};

                        // 1-stage and vector feature output
                        o_pkt_size_r                <=        pkt_size_r2;
                        o_pkt_arit_r                <=        'd0;
                        o_n_pkt_r                   <=        'd1;
                        o_size_arit_v_r             <=        'd1;
                        o_flow_durt_r               <=        'd0;
                        o_flow_size_r               <=        pkt_size_r2;
                        o_reach_thrh_r              <=        'd0;

                        // tb signal
                        master_wnpkt_r_tb           <=          8'd1;
                        slave_wnpkt_r_tb            <=          8'd1;
                    end
                    // an in-flight flow, need not free
                    else begin
                        wr_ram_master            <=        1'b0;
                        wr_ram_slave             <=        1'b0;
                        master_ram_wdata         <=        50'd0;
                        slave_ram_wdata          <=        50'd0;
                        slave_ram_waddr           <=        32'd0;
                        hit                      <=        1'd0;

                        // 1-stage and vector feature output
                        o_pkt_size_r             <=        'd0;
                        o_pkt_arit_r             <=        'd0;
                        o_n_pkt_r                <=        'd0;
                        o_size_arit_v_r          <=        'd0;
                        o_flow_durt_r            <=        'd0;
                        o_flow_size_r            <=        'd0;
                        o_reach_thrh_r           <=        'd0;

                        // free state signal
                        wr_free_state_ram_master_g0    <=      1'b0;
                        wr_free_state_ram_slave_g0     <=      1'b0;
                        wr_free_state_ram_master_g1    <=      1'b0;
                        wr_free_state_ram_slave_g1     <=      1'b0;
                        
                        // tb signal
                        master_wnpkt_r_tb        <=          n_pkt;
                        slave_wnpkt_r_tb         <=          n_pkt;
                    end
                end
                
            end
            
            2'b11: begin // a master pkt, when current used to be r_hash
                // this bit is used for judging reach_thrh
                if(master_ram_rdata_r1[1] == 'd0) begin  // not reach thrh
                    hit                        <=        1'd1;

                    wr_ram_master              <=        1'b1;
                    wr_ram_slave               <=        1'b1;
                    
                    // update master ram for master direction, and same for slave ram to keep data consisteny
                    //                              1st_pkt_arvt,  last_pkt_arvt, flow_durt,                   flow_size,             n_pkt,      pkt_arit,                     flag
                    master_ram_waddr            <=        hash_r2;

                    slave_ram_waddr             <=        r_hash_r2;
                
                    // 1-stage and vector feature output
                    o_pkt_size_r               <=        pkt_size_r2;
                    o_pkt_arit_r               <=        pkt_arvt_r2-slave_last_pkt_arvt;
                    o_n_pkt_r                  <=        slave_n_pkt+1'b1;
                    o_size_arit_v_r            <=        'd1;
                    o_flow_durt_r              <=        pkt_arvt_r2-first_pkt_arvt;
                    o_flow_size_r              <=        flow_size+pkt_size_r2;
                    if (n_pkt+1'b1 >= threshold_r) begin
                        master_ram_wdata       <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b11};
                        slave_ram_wdata        <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b11};
                        o_reach_thrh_r         <=        'd1;
                        // tb signal
                        master_wnpkt_r_tb      <=          n_pkt+1'b1;
                        slave_wnpkt_r_tb       <=          n_pkt+1'b1;
                    end
                    else begin
                        master_ram_wdata       <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b01};
                        slave_ram_wdata        <=        {first_pkt_arvt, pkt_arvt_r2, pkt_arvt_r2-first_pkt_arvt, flow_size+pkt_size_r2, n_pkt+1'b1, pkt_arvt_r2-last_pkt_arvt, 2'b01};
                        o_reach_thrh_r         <=        'd0;
                        // tb signal
                        master_wnpkt_r_tb      <=          n_pkt+1'b1;
                        slave_wnpkt_r_tb       <=          n_pkt+1'b1;
                    end
                end


                // flow that reach_thrh
                // if reach thrh:
                // 1. if this address is ready-to-be-free, then update as a brand new flow
                // 2. this address is in-flight, thus nothing needs to be done
                else begin
                    // free current addr and let new flow in
                    if(master_free_r1_g0 || master_free_r1_g1) begin
                        // wr free state ram
                        wr_free_state_ram_master_g0    <=      1'b1;
                        wr_free_state_ram_slave_g0     <=      1'b1;
                        wr_free_state_ram_master_g1    <=      1'b1;
                        wr_free_state_ram_slave_g1     <=      1'b1;

                        hit                         <=        1'd0;
                        // flag both master and slave ram
                        wr_ram_master               <=        1'b1;
                        wr_ram_slave                <=        1'b1;

                        // master ram and slave ram use different addr
                        master_ram_waddr            <=        hash_r2;
                        slave_ram_waddr             <=        r_hash_r2;

                        // set initial val for first pkt, and same for slave ram to keep data consisteny
                        //                                    1st_pkt_arvt, last_pkt_arvt, flow_durt, flow_size,     n_pkt, pkt_arit, flag
                        master_ram_wdata            <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};
                        slave_ram_wdata             <=        {pkt_arvt_r2, pkt_arvt_r2,      8'd0,         pkt_size_r2, 8'd1,    8'd0,      2'b01};

                        // 1-stage and vector feature output
                        o_pkt_size_r                <=        pkt_size_r2;
                        o_pkt_arit_r                <=        'd0;
                        o_n_pkt_r                   <=        'd1;
                        o_size_arit_v_r             <=        'd1;
                        o_flow_durt_r               <=        'd0;
                        o_flow_size_r               <=        pkt_size_r2;
                        o_reach_thrh_r              <=        'd0;

                        // tb signal
                        master_wnpkt_r_tb           <=          8'd1;
                        slave_wnpkt_r_tb            <=          8'd1;
                    end
                    // an in-flight flow, need not free
                    else begin
                        wr_ram_master            <=        1'b0;
                        wr_ram_slave             <=        1'b0;
                        master_ram_wdata         <=        50'd0;
                        slave_ram_wdata          <=        50'd0;
                        slave_ram_waddr           <=        32'd0;
                        hit                      <=        1'd0;

                        // 1-stage and vector feature output
                        o_pkt_size_r             <=        'd0;
                        o_pkt_arit_r             <=        'd0;
                        o_n_pkt_r                <=        'd0;
                        o_size_arit_v_r          <=        'd0;
                        o_flow_durt_r            <=        'd0;
                        o_flow_size_r            <=        'd0;
                        o_reach_thrh_r           <=        'd0;

                        // free state signal
                        wr_free_state_ram_master_g0    <=      1'b0;
                        wr_free_state_ram_slave_g0     <=      1'b0;
                        wr_free_state_ram_master_g1    <=      1'b0;
                        wr_free_state_ram_slave_g1     <=      1'b0;
                        
                        // tb signal
                        master_wnpkt_r_tb        <=          n_pkt;
                        slave_wnpkt_r_tb         <=          n_pkt;
                    end
                end
                
            end


            default: begin
                wr_ram_master            <=        1'b0;
                wr_ram_slave             <=        1'b0;
                master_ram_wdata         <=        50'd0;
                slave_ram_wdata          <=        50'd0;
                slave_ram_waddr           <=        32'd0;
                hit                      <=        1'd0;

                // 1-stage and vector feature output
                o_pkt_size_r             <=        'd0;
                o_pkt_arit_r             <=        'd0;
                o_n_pkt_r                <=        'd0;
                o_size_arit_v_r          <=        'd0;
                o_flow_durt_r            <=        'd0;
                o_flow_size_r            <=        'd0;
                o_reach_thrh_r           <=        'd0;

                // tb signal
                master_wnpkt_r_tb        <=        'd0;
                slave_wnpkt_r_tb         <=        'd0;
            end
            endcase
        end
        else begin
            wr_ram_master                   <=        1'b0;
            wr_ram_slave                    <=        1'b0;
            master_ram_wdata                <=        50'd0;
            slave_ram_wdata                 <=        50'd0;
            being_judge_hit                 <=        1'd0;
            hit                             <=        1'd0;

            // 1-stage and vector feature output
            o_pkt_size_r                    <=        'd0;
            o_pkt_arit_r                    <=        'd0;
            o_n_pkt_r                       <=        'd0;
            o_size_arit_v_r                 <=        'd0;
            o_flow_durt_r                   <=        'd0;
            o_flow_size_r                   <=        'd0;
            o_reach_thrh_r                  <=        'd0;

            wr_free_state_ram_master_g0        <=        1'd0;
            wr_free_state_ram_slave_g0         <=        1'd0;
            wr_free_state_ram_master_g1        <=        1'd0;
            wr_free_state_ram_slave_g1         <=        1'd0;

            // tb signal
            master_wnpkt_r_tb               <=        8'd0;
            slave_wnpkt_r_tb                <=        8'd0;
        end
    end
end



/*  
    The data-format of two state ram: 
    Size is in 50bit x 4k.
    49b-42b            41b-34b            33b-26b        25b-18b        17b-10b        9b-2b        1b-0b
    1st_pkt_arvt    last_pkt_arvt    flow_durt    flow_size    n_pkt        pkt_arit    flag

*/

// used for tracking flow with hash value of positive direction
TRACKER_STATE_RAM state_ram_master(
    // wr port
    .addra                          (master_ram_waddr[11:0]),
    .clka                           (clk),
    .dina                           (master_ram_wdata),
    .wea                            (wr_ram_master),

    // rd port
    .addrb                          (hash[11:0]),
    .doutb                          (master_ram_rdata),
    .clkb                           (clk),
    .enb                            (1'b1)
    // .enb                            (hash_v|tracked_state_v|tracked_state_v_r0)
);

// used for tracking flow with reverse hash value
TRACKER_STATE_RAM state_ram_slave(
    // wr port
    .addra                          (slave_ram_waddr[11:0]), // r_hash or hash, hash in new flow cases
    .clka                           (clk),
    .dina                           (slave_ram_wdata),
    .wea                            (wr_ram_slave),

    // rd port
    .addrb                          (hash[11:0]),
    .doutb                          (slave_ram_rdata),
    .clkb                           (clk),
    .enb                            (1'b1)
    // .enb                            (hash_v|tracked_state_v|tracked_state_v_r0)
);


reg     [49:0]                          master_ram_rdata_r0;
reg     [49:0]                          slave_ram_rdata_r0;
reg     [49:0]                          master_ram_rdata_r1;
reg     [49:0]                          slave_ram_rdata_r1;
reg     [49:0]                          master_ram_rdata_r2;
reg     [49:0]                          slave_ram_rdata_r2;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        master_ram_rdata_r0                <=              50'd0;
        slave_ram_rdata_r0                 <=              50'd0;
        master_ram_rdata_r1                <=              50'd0;
        slave_ram_rdata_r1                 <=              50'd0;
        master_ram_rdata_r2                <=              50'd0;
        slave_ram_rdata_r2                 <=              50'd0;
    end
    else begin
        master_ram_rdata_r0                <=              master_ram_rdata;
        master_ram_rdata_r1                <=              master_ram_rdata_r0;
        master_ram_rdata_r2                <=              master_ram_rdata_r1;

        slave_ram_rdata_r0                 <=              slave_ram_rdata;
        slave_ram_rdata_r1                 <=              slave_ram_rdata_r0;
        slave_ram_rdata_r2                 <=              slave_ram_rdata_r1;
    end
end




integer fd1;
initial begin
    //existing file
    fd1 = $fopen("D:\\CodeFactory\\TFE\\proj\\debug_log\\debug0.txt", "w");    //打开存在的文件
    # 1000;
    $fclose(fd1);
end

always @ (posedge clk) begin
    if(wr_ram_master) begin
        $fwrite(fd1, "%d    %d    %d\n", pkt_arvt_r3, master_ram_waddr, wn_pkt);
    end
end



// free state ram group 0
wire                                    master_free_g0;
wire                                    slave_free_g0;
reg                                     master_free_r0_g0;
reg                                     master_free_r1_g0;
reg                                     master_free_r2_g0;
reg                                     slave_free_r0_g0;
reg                                     slave_free_r1_g0;
reg                                     slave_free_r2_g0;
reg                                     wr_free_state_ram_master_g0;
reg                                     wr_free_state_ram_slave_g0;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        master_free_r0_g0                  <=      'd0;
        master_free_r1_g0                  <=      'd0;
        master_free_r2_g0                  <=      'd0;
        slave_free_r0_g0                   <=      'd0;
        slave_free_r1_g0                   <=      'd0;
        slave_free_r2_g0                   <=      'd0;
    end
    else begin
        master_free_r0_g0                  <=      master_free_g0;
        master_free_r1_g0                  <=      master_free_r0_g0;
        master_free_r2_g0                  <=      master_free_r1_g0;
        slave_free_r0_g0                   <=      slave_free_g0;
        slave_free_r1_g0                   <=      slave_free_r0_g0;
        slave_free_r2_g0                   <=      slave_free_r1_g0;
    end
end

// free state ram group 1
wire                                    master_free_g1;
wire                                    slave_free_g1;
reg                                     master_free_r0_g1;
reg                                     master_free_r1_g1;
reg                                     master_free_r2_g1;
reg                                     slave_free_r0_g1;
reg                                     slave_free_r1_g1;
reg                                     slave_free_r2_g1;
reg                                     wr_free_state_ram_master_g1;
reg                                     wr_free_state_ram_slave_g1;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        master_free_r0_g1                  <=      'd0;
        master_free_r1_g1                  <=      'd0;
        master_free_r2_g1                  <=      'd0;
        slave_free_r0_g1                   <=      'd0;
        slave_free_r1_g1                   <=      'd0;
        slave_free_r2_g1                   <=      'd0;
    end
    else begin
        master_free_r0_g1                  <=      master_free_g1;
        master_free_r1_g1                  <=      master_free_r0_g1;
        master_free_r2_g1                  <=      master_free_r1_g1;
        slave_free_r0_g1                   <=      slave_free_g1;
        slave_free_r1_g1                   <=      slave_free_r0_g1;
        slave_free_r2_g1                   <=      slave_free_r1_g1;
    end
end

// used for tracking free state
FREE_STATE_RAM free_state_ram_master_g0(
    // tfe port
    .addra                          (hash[11:0]), // r_hash or hash, hash in new flow cases
    .clka                           (clk),
    .dina                           (1'b0),
    .douta                          (master_free_g0),
    .wea                            (wr_free_state_ram_master_g0),

    // external port
    .addrb                          (free_addr),
    .dinb                           (1'b1),
    .doutb                          (),
    .clkb                           (clk),
    .web                            (free_addr_v)
);

FREE_STATE_RAM free_state_ram_slave_g0(
    // tfe port
    .addra                          (r_hash[11:0]), // r_hash or hash, hash in new flow cases
    .clka                           (clk),
    .dina                           (1'b0),
    .douta                          (slave_free_g0),
    .wea                            (wr_free_state_ram_slave_g0),

    // external port
    .addrb                          (free_addr),
    .dinb                           (1'b1),
    .doutb                          (),
    .clkb                           (clk),
    .web                            (free_addr_v)
);


FREE_STATE_RAM free_state_ram_master_g1(
    // tfe port
    .addra                          (hash[11:0]), // r_hash or hash, hash in new flow cases
    .clka                           (clk),
    .dina                           (1'b0),
    .douta                          (master_free_g1),
    .wea                            (wr_free_state_ram_master_g1),

    // external port
    .addrb                          (free_r_addr),
    .dinb                           (1'b1),
    .doutb                          (),
    .clkb                           (clk),
    .web                            (free_addr_v)
);

FREE_STATE_RAM free_state_ram_slave_g1(
    // tfe port
    .addra                          (r_hash[11:0]), // r_hash or hash, hash in new flow cases
    .clka                           (clk),
    .dina                           (1'b0),
    .douta                          (slave_free_g1),
    .wea                            (wr_free_state_ram_slave_g1),

    // external port
    .addrb                          (free_r_addr),
    .dinb                           (1'b1),
    .doutb                          (),
    .clkb                           (clk),
    .web                            (free_addr_v)
);
endmodule
