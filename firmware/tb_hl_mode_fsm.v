// tb_hl_mode_fsm.v
`timescale 1ns/1ps

module tb_hl_mode_fsm;

    reg clk   = 0;
    reg rst_n = 0;

    // emulate active-HIGH pressed buttons (invert in top-level if your board is active-LOW)
    reg btn_mode   = 0;
    reg btn_echo   = 0;
    reg btn_noise  = 0;
    reg btn_filter = 0;

    wire mode_is_loss, echo_en, noise_en, filter_en;

    hl_mode_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_mode(btn_mode),
        .btn_echo(btn_echo),
        .btn_noise(btn_noise),
        .btn_filter(btn_filter),
        .mode_is_loss(mode_is_loss),
        .echo_en(echo_en),
        .noise_en(noise_en),
        .filter_en(filter_en)
    );

    // 50 MHz-ish
    always #10 clk = ~clk;

    task press(input reg btn_ref);
        begin
            // drive high for a few cycles to simulate a press
            btn_ref = 1'b1;  repeat (3) @(posedge clk);
            btn_ref = 1'b0;  repeat (5) @(posedge clk);
        end
    endtask

    initial begin
        $display("Start TB");
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (3) @(posedge clk);

        // Toggle mode twice: LOSS->AID->LOSS
        press(btn_mode);
        $display("[t=%0t] mode_is_loss=%0d", $time, mode_is_loss);
        press(btn_mode);
        $display("[t=%0t] mode_is_loss=%0d", $time, mode_is_loss);

        // Toggle features
        press(btn_echo);
        press(btn_noise);
        press(btn_filter);

        $display("[t=%0t] echo=%0d noise=%0d filter=%0d", $time, echo_en, noise_en, filter_en);

        // Toggle some again
        press(btn_echo);
        press(btn_filter);

        $display("[t=%0t] echo=%0d noise=%0d filter=%0d", $time, echo_en, noise_en, filter_en);

        repeat (10) @(posedge clk);
        $finish;
    end

endmodule
