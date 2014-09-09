%.
function history = bcmdp_save_check(s,a,r,s_,w,history,t,episode,bc,mdp)
    %todo: how to store w's in history?
    
    fields = fieldnames(w);
    num_vec = numel(fields);
    
    %check if any of your weight vectors exploded--then get out of there,
    %no point in wasting cpu time
    for i = 1:num_vec
        name = fields{i};
        if ~isempty(find(isnan(w.(name)),1 ) )
            history.NaN_flag = true;
            return
        end
    end
    Xs = history.Xs;
    As = history.As;
    Rs = history.Rs;
    if t == 1
       %initialize X,A,R
       X = zeros(bc.n,bc.T);
       A = zeros(bc.n,bc.T);
       R = zeros(1,bc.T);
    else
        X = Xs{episode}; 
        A = As{episode};
        R = Rs{episode};
    end
    
    %%update all of the histories
    %can't directly reference cells from struct--will overwrite
    
    X(:,t) = s;
    Xs{episode} = X;
    history.Xs = Xs;
    
    A(:,t) = a(1:bc.n,:);
    As{episode} = A;
    history.As = As;
    
    R(t) = r;
    Rs{episode} = R;
    history.Rs = Rs;
    
    if strcmpi(mdp.run_type,'learn')
        %input all of the norms of things in w
        w_fields = fieldnames(w);
        Ws = history.Ws;
        for i = 1:numel(w_fields)
            name = w_fields{i};
            v = w.(name);
            if strcmpi(mdp.plot_type,'L1')
                val = norms(v,1,1)';
            elseif strcmpi(mdp.plot_type,'L2')
                val = norms(v,2,1)';
            end
            Ws.(name)(:,(episode-1)*bc.T + t) = val;
        end
        history.Ws = Ws;
    end
    
end