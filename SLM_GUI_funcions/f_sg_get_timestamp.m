function timestamp_out = f_sg_get_timestamp()

time_stamp = clock;

timestamp_out = sprintf('%d_%d_%d_%dh_%dm', time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4), time_stamp(5));

end