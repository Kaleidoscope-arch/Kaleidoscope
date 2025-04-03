/*  
    This file is the hashing function module of the TFE. It receives IP
    tuple, outputing hash value and reverse hash value of the tuple. Re-
    verse hash value is defined as the hash value with reverse direction
    IP tuple. 
*/

module Hashing (
    input                                           clk,
    input                                           rst_n,

    input   [103:0]                                 ip_tuple,
    input   [103:0]                                 r_ip_tuple,
    input                                           ip_tuple_v,

    output  reg [31:0]                              hash,
    output  reg [31:0]                              r_hash,
    output  reg                                     hash_v
);







always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hash_v                                      <=          'd0;
        hash                                        <=          32'd0;
        r_hash                                      <=          32'd0;
    end
    else begin
        if(ip_tuple_v) begin
            hash_v                                  <=          'd1;
        end
        else begin
            hash_v                                  <=          'd0;
        end
        
        hash                                        <=          hash_w;
        r_hash                                      <=          r_hash_w;
    end
end


wire    [31:0]                                      hash_w;
wire    [31:0]                                      r_hash_w;


CRC32_D104 hash_gener(
    .d                                  (ip_tuple),
    .crc_last                           (32'hffff_ffff),
    .crc_out                            (hash_w)
);

CRC32_D104 r_hash_gener(
    .d                                  (r_ip_tuple),
    .crc_last                           (32'hffff_ffff),
    .crc_out                            (r_hash_w)
);
endmodule
