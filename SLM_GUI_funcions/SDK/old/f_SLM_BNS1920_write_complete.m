function write_complete = f_SLM_BNS1920_write_complete(ops)

write_complete = calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);

end