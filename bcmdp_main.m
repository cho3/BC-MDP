%bcmdp_main.m
%the main loop, runs all of the requisite functions/scripts

%do single agent case, compare multiple independent agents to coordinated
%policies (for constant budget per agent)
%then do continuous action stuff (same thing)
%do something that can parameterize a random variable that only lives in a
%probability simplex--so somehow parameterize a multinomial distribution?
%(dirichlet???)

%compare hist features to explicit feature repr
%also compare number of bins for this particular problem


%initialize the bc and mdp structs, cast the functions into the correct
%form
% bcmdp_init;
%running from bcmdp_init is easier

%init w's somehow--separate function that depends on feature function and
%learning rule? might be best to have in init

for episode = 1:mdp.n_episodes
    
    %initial state and action
    s = bcmdp_init_s(episode,bc,mdp);
    if mdp.MAS > 1 && mdp.m == 1
        phi = zeros(num_features,mdp.MAS);
        for k = 1:mdp.MAS
            phi(:,k) = featureFunction(s,k);
        end
    else
        phi = featureFunction(s);
    end
    if strcmpi(mdp.run_type,'dynamics')
        a = [zeros(bc.n,1); randi(size(mdp.A,2),mdp.MAS,1)];
    else
        a = getAction(s,w,phi);
        %if lam ~= 0, initialize eligibility traces to zeros    
        %reset trace
        w.e = zeros(num_features*size(mdp.A,2),mdp.MAS);
        %if im using average reward as a trace, reset reward trace
    %     w.r_avg = 0;
    end

    
    for t = 1:bc.T
        
        s_ = getNext(s,a);
        %get reward from taking an action, and ending up in a given state,
        %might be wrong
        r = getReward(s_,a);
        
        if isEnd(s_)
            r = 1;
        end
        
        if strcmpi(mdp.run_type,'dynamics')
            a_ = zeros(bc.n,1);
        else
            if mdp.MAS > 1 && mdp.m == 1
                phi_ = zeros(num_features,mdp.MAS);
                for k = 1:mdp.MAS
                    phi_(:,k) = featureFunction(s,k);
                end
            else
                phi_ = featureFunction(s);
            end
            a_ = getAction(s_,w,phi_);
        end
        
        %this might be a tuple/structure
        if strcmpi(mdp.run_type,'learn')
            w = update(s,a,r,s_,a_,w,phi,phi_);
        else
            w.a = zeros(50,1);
        end
        
        history = next(s,a,r,s_,w,history,t,episode);
        
        if history.NaN_flag
            disp('Err NaN in weights, ending run...');
            break
        end
        
        if isEnd(s_)
            break
        end
        
        s = s_;
        a = a_;
        if ~strcmpi(mdp.run_type,'dynamics')
            phi = phi_;
        end
        
    end
    
    if history.NaN_flag
        break
    end
    
    %maybe plot
    if episode == mdp.n_episodes && num_runs <= 1
        plot_episode(history,episode);
    end
    
    if mod(episode,mdp.display_episode_interval) == 0 && num_runs <= 1
        disp(['Episode ' int2str(episode) ' Completed!']);
    end
    
end

%plot weights
if strcmpi(mdp.run_type,'learn') && num_runs <= 1
    figure;
    plot_norms(history);
end