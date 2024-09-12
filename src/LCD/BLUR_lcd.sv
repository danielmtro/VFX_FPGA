import lcd_inst_pkg::*;
	
module BLUR_lcd (
    input  logic clk,
    input  logic reset,
    // Avalon-MM signals to LCD_Controller slave:
    output logic address,
    output logic chipselect,
    output logic byteenable,
    output logic read,
    output logic write,
    input  logic waitrequest,
    input  logic [7:0] readdata,
    input  logic [1:0] response,
    output logic [7:0] writedata
);
    // State encoding for FSM
    typedef enum logic [1:0] {IDLE, WRITE_OP} state_t;
    state_t current_state, next_state;

    localparam N_INSTRS = 5; // Change this to the number of instructions you have below:
    logic [8:0] instructions [N_INSTRS] = '{CLEAR_DISPLAY, _b, _l, _u, _r}; // Clear display then display "Colour".
    // In the above array, **bit-8 is the 1-bit `address`** and bits 7 down-to 0 give the 8-bit data.

    integer instruction_index = 0; // You can use these to count.

    // Your code here! (FSM always_ff, always_comb, etc).

    // all the stuff in the specification
    assign chipselect = write;
    assign byteenable = write;
    assign read = 1'b0;    



    always_comb begin: fsm_next_state
        case(current_state)
            IDLE: next_state = (instruction_index < N_INSTRS) ? WRITE_OP : IDLE;
            WRITE_OP: next_state = (waitrequest && (instruction_index != N_INSTRS)) ? WRITE_OP : IDLE;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin: fsm_ff
        if (reset) begin
            instruction_index <= 0;
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
            case (current_state)
                IDLE: begin
                    instruction_index <= instruction_index; // don't increment in idle state
                end
                WRITE_OP: begin
                    if (!waitrequest) begin
                        instruction_index <= instruction_index + 1; // increment
                    end
                end
            endcase
        end
    end

    always_comb begin: fsm_output
        address = (instruction_index == 0) ? 1'b0 : 1'b1;
        writedata = instructions[instruction_index];
        case(current_state)
            IDLE: begin
                write = 1'b0;
            end
            WRITE_OP: begin
                write = 1'b1;
            end
        endcase
    end

endmodule