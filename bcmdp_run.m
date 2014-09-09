%bcmdp_run.m
%run random crap for long stuff--don't include any serious logic in here,
%this is for dumb stuff, if you're going to have real logic do proper
%programming


histories1 = cell(num_runs,1);
bc.beta = 0.1;
%run the program
total_time = 0;
for run = 1:num_runs
    bcmdp_init_history;
    t0 = tic;
    bcmdp_main;
    tf = toc(t0);
    total_time = total_time + tf;
    disp(['Run ' int2str(run) ' Complete! It took ' int2str(tf) ' seconds!']);
    histories1{run} = history;
end
w1 = w;

histories2 = cell(num_runs,1);
bc.beta = 0.05;
%run the program
total_time = 0;
for run = 1:num_runs
    bcmdp_init_history;
    t0 = tic;
    bcmdp_main;
    tf = toc(t0);
    total_time = total_time + tf;
    disp(['Run ' int2str(run) ' Complete! It took ' int2str(tf) ' seconds!']);
    histories2{run} = history;
end
w2 = w;

histories3 = cell(num_runs,1);
bc.beta = 0.02;
%run the program
total_time = 0;
for run = 1:num_runs
    bcmdp_init_history;
    t0 = tic;
    bcmdp_main;
    tf = toc(t0);
    total_time = total_time + tf;
    disp(['Run ' int2str(run) ' Complete! It took ' int2str(tf) ' seconds!']);
    histories3{run} = history;
end
w3 = w;
