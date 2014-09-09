%%cast functions to be from the bcmdp_* form to the * form unparameterized
%
%move this code to bcmdp_init_history
getNext = @(s,a) bcmdp_getNext(s,a,bc);
if strcmpi(mdp.feature_type,'tile')
    getTiles = initTileCode(2,[mdp.n_bins, mdp.n_bins],mdp.num_tiles);
    num_feat = numel(getTiles([0 0]));
    if mdp.MAS > 1 && mdp.m == 1
        featureFunction = @(s,k) bcmdp_featureFunctionTiles(s,k,getTiles,num_feat,bc,mdp);
    else
        featureFunction = @(s) bcmdp_featureFunctionTiles(s,0,getTiles,num_feat,bc,mdp);
    end
    num_features = num_feat*mdp.m;
elseif strcmpi(mdp.feature_type,'explicit_tile')
    getTiles = initTileCode(bc.n,mdp.n_bins,mdp.num_tiles);
    featureFunction = @(s) getTiles(s);
    num_feat = numel(featureFunction(rand(bc.n,1)));
    num_features = num_feat*mdp.m;
elseif strcmpi(mdp.feature_type,'linear')
    if mdp.MAS > 1 && mdp.m == 1
        featureFunction = @(s,k) bcmdp_featureFunctionLin(s,k,bc,mdp);
    else
        featureFunction = @(s) bcmdp_featureFunctionLin(s,0,bc,mdp);
    end
    num_features = size(featureFunction(rand(bc.n,1)),1);
else
    if mdp.MAS > 1 && mdp.m == 1
        featureFunction = @(s,k) bcmdp_featureFunctionBin(s,k,bc,mdp);
    else
        featureFunction = @(s) bcmdp_featureFunctionBin(s,0,bc,mdp);
    end
    num_features = size(featureFunction(rand(bc.n,1)),1);
end
getAction = @(s,w,phi) bcmdp_getActionDiscrete(s,w,phi,bc,mdp);
getReward = @(s_,a) bcmdp_getReward(s_,a,bc,mdp);
update = @(s,a,r,s_,a_,w,phi,phi_) bcmdp_update(s,a,r,s_,a_,w,phi,phi_,bc,mdp);
next = @(s,a,r,s_,w,history,t,episode) ...
    bcmdp_save_check(s,a,r,s_,w,history,t,episode,bc,mdp);
isEnd = @(s) bcmdp_stop_crit(s,bc,mdp);

%most likely dependent on some other set of parameters, not bc or mdp
plot_episode = @(history,T) bcmdp_plot_episode(history,T,bc,mdp);
plot_norms = @(history) bcmdp_plot_norms(history,bc,mdp);

%initialize history,w

history.Xs = {};
history.As = {};
history.Rs = {};
history.NaN_flag = false;
if strcmpi(mdp.run_type,'learn')
%     w = [];
    
    %initialize w or something somehow
    %eligility trace, w.e gets initialized in main loop
%     if mdp.lambda > 0
% %         w.e = zeros(num_features*numel(mdp.A),1); %need some placeholder for 
%         %featurefunction size
%     end
    if mdp.alpha_r > 0
        w.r_avg = 0; 
        w.step  = 0;
        %this might not be right because i might need to reinitialize it to
        %0 at each episode, (since its a trace?), but im using it for
        %relative rewards, so yeah...
    end
    %if we are operating in a finite action space (since Q(s,a) =
    %w_a'*phi(s) by my formulation
    if strcmpi(mdp.learning_rule,'q') || strcmpi(mdp.learning_rule,'sarsa')
        w.Wa = zeros(num_features,numel(A));
    end
    
    if strcmpi(mdp.learning_rule,'copdac-gq') || strcmpi(mdp.learning_rule,'tdc')...
            || strcmpi(mdp.learning_rule,'gtd2')
        w.Wa = zeros(num_features,numel(A));
        w.u = zeros(num_features,1);
    end
    
    w.e = zeros(num_features*size(mdp.A,2),mdp.MAS);
    %count number of vectors involved in w
    fields = fieldnames(w);
    for i = 1:numel(fields)
        Ws.(fields{i}) = zeros(size(w.(fields{i}),2),bc.T*mdp.n_episodes);
    end
    history.Ws = Ws;
end