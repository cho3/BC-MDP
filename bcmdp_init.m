%bcmdp_init.m 
%initialize all bc and mdp structs, cast bcmdp_* functions as * functions
% clear
%%settings for bounded confidence model/dynamics
%number of agents
bc.n = 2;
%right and left confidence bounds
bc.eps_r = 0.15;
bc.eps_l = bc.eps_r;
% % bc.eps_l = 0.25;
%probability of no msg (or it might be prob of a msg going through...)
bc.p = 0.8;%0.2;
%probability of wrong msg (round)
bc.q = 0.05;%0.05;
%whether initial conditions are uniform linspace  'unif' or random 'rand'
%-- have to do random start, since the first m agents are controlled
%also include 'fixrand'--predetermined random starts for each episode
bc.init = 'rand';
%time horizon for each episode
bc.T = 500;
%budget (amount of total control effort)
% % bc.beta = 0.2/bc.n; %usually use 0.1, 0.05, 0.02
bc.beta = 0.066;

%%settings for mdp
%number of agents to control
mdp.m = 1;
%number of independent agents, only works if m = 1, if using coordinated
%agents, set MAS to 1
mdp.MAS = 1;
if mdp.MAS > 1 && mdp.m > 1
    error('Using multiple independent agents requires mdp.m = 1');
end
%number of bins with which to discretize the spans [del,eps_r] and
%[-eps_l,-del]; total number of features is 2*n_bins+3
mdp.n_bins = 13;
mdp.n_episodes = 15000;
%whether we are learning a weights/whatever, trying out a given w, or just
%checking the dynamics of the system: 'learn','policy', or 'dynamics
mdp.run_type = 'learn'; 
%what kind of reward function: 'L1', 'L2', or 'const'
mdp.reward_fn = 'const';
%goal state, a function of the mdp, not the dynamics
mdp.goal = 0.75;
%if everyone is within this distance of the goal state, we're done
mdp.stop_thresh = 0.05;
%eps: prob of random action
mdp.eps = 0.2;
%corresponds to weight on each element of the reward function
%distance from goal is always weight 1 (implicit), second is the diameter
%of the agents' belief space, third is the variance in belief values
%these encode deviance/spread
mdp.J = [0 0];
%decay rate of eligility traces (if used)
mdp.lambda = 1;
%trace type, 'accumulating' or 'replacing'
mdp.trace_type = 'replacing';
%discount factor
mdp.gamma = 1;
%learning rates
mdp.alpha_w = 0.03;
mdp.alpha_r = 0.1;%0.001; %use relative reward
mdp.alpha_u = 0.03;
%more learning rates...
%
%if using softmax, need to define temperature, tau
mdp.tau = 25;
%what kind of resource allocation, uniform or dirichlet
mdp.resource_alloc = 'unif';
%number of tiles if using tile coding
mdp.num_tiles = 10;
%action space, each action is indexed by cell (e.g. 1,2,...,9)
as_ = repmat([-1 0 1],1,mdp.m);
A_ = unique(combntns(as_,mdp.m),'rows');
% A = {[0 1],[1 1],[-1 1]};
A = A_';
% A = cell(size(A_,1),1);
% for i = 1:size(A_,1)
%     A{i} = [A_(i,:)'];%;zeros(bc.n-mdp.m,1)];
% end
mdp.A = A;
%===DEPRICATED BY REALIZATION OF MDP.A===
%indicator vector (for AND) of which agents are controllable
% mdp.U = zeros(bc.n,1);
%========================================
%max number of features;
mdp.M = 10000;
%the width of the feature bin that corresponds to something being 'zero'
mdp.del = 0.08;
% 'explicit' or 'hist' or 'tile' for now
mdp.feature_type = 'explicit_tile';
%how to handle the histogram-like 'binary','sqrt', anything else means no
%scaling
mdp.feature_scaling = 'unscaled';
% 'softmax' or 'hardmax' for now
mdp.action_type = 'hardmax';
if ~strcmpi(mdp.run_type,'learn')
    mdp.n_episodes = 1;
end
%what learning algorithm to use: 'q','sarsa','tdc','gtd2','copdac-gq'
mdp.learning_rule = 'tdc';
%what norm to plot for plotnorms and saving norms
mdp.plot_type = 'L2';
mdp.display_episode_interval = 50;

if strcmpi(bc.init,'fixrand')
    mdp.s0 = rand(bc.n,mdp.n_episodes);
end

num_runs = 1;
% bcmdp_run;

%num_runs is not a property of the bc dynamics or the mdp... it's a
%metavariable
% num_runs = 1;
histories = cell(num_runs,1);
%run the program
total_time = 0;
for run = 1:num_runs
    bcmdp_init_history;
    t0 = tic;
    bcmdp_main;
    tf = toc(t0);
    total_time = total_time + tf;
    disp(['Run ' int2str(run) ' Complete! It took ' int2str(tf) ' seconds!']);
    histories{run} = history;
end
if num_runs > 1
    disp(['All ' int2str(num_runs) ' runs took ' int2str(total_time) ' seconds!']);
    figure;
    bcmdp_plot_avg(histories,bc,mdp);
end