module hl_mode_fsm (
    input  wire clk,
    input  wire rst_n,               // active-low async reset

    // raw async button inputs (active-low on many boards; pass already inverted if needed)
    input  wire btn_mode,            // toggle LOSS <-> AID
    input  wire btn_echo,            // toggle echo enable
    input  wire btn_noise,           // toggle noise enable
    input  wire btn_filter,          // toggle filter enable

    // status outputs
    output reg  mode_is_loss,        // 1 = LOSS_SIM, 0 = AID_SIM
    output reg  echo_en,
    output reg  noise_en,
    output reg  filter_en
);

    // ----------- Synchronize & one-pulse the buttons -----------
    wire mode_pulse, echo_pulse, noise_pulse, filter_pulse;

    one_pulse u_p_mode  (.clk(clk), .rst_n(rst_n), .btn(btn_mode),  .pulse(mode_pulse));
    one_pulse u_p_echo  (.clk(clk), .rst_n(rst_n), .btn(btn_echo),  .pulse(echo_pulse));
    one_pulse u_p_noise (.clk(clk), .rst_n(rst_n), .btn(btn_noise), .pulse(noise_pulse));
    one_pulse u_p_filter(.clk(clk), .rst_n(rst_n), .btn(btn_filter),.pulse(filter_pulse));

    // ----------- State/flags -----------
    // Mode flip-flop and three feature flip-flops.
    // Reset defaults: LOSS mode, all effects off (feel free to change).
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode_is_loss <= 1'b1; // default to LOSS_SIM
            echo_en      <= 1'b0;
            noise_en     <= 1'b0;
            filter_en    <= 1'b0;
        end else begin
            if (mode_pulse)  mode_is_loss <= ~mode_is_loss;
            if (echo_pulse)  echo_en      <= ~echo_en;
            if (noise_pulse) noise_en     <= ~noise_en;
            if (filter_pulse)filter_en    <= ~filter_en;
        end
    end

endmodule

module one_pulse (
    input  wire clk,
    input  wire rst_n,
    input  wire btn,       // assumed active-HIGH press after any external inversion
    output wire pulse
);
    // 2FF synchronizer
    reg [1:0] sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sync <= 2'b00;
        else        sync <= {sync[0], btn};
    end

    // edge detect: rising edge from sync[1:0]
    reg sync_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sync_d <= 1'b0;
        else        sync_d <= sync[1];
    end

    assign pulse = (sync[1] & ~sync_d); // 1 clk pulse on rising edge
endmodule
