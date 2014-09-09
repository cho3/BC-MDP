%bcmdp_getAction.m
%use a feature function and get the action
%can also have policy gradient type things idk how
function a = bcmdp_getActionDiscrete(s,w,phi,bc,mdp)
    %w is a structure of weight vectors
    %how to store feature function (mdp property or separate function
    %phi = phi(s), phi_ = phi(s_)
    
    W = w.Wa;
    q = W'*phi;
    
    if strcmpi(mdp.action_type,'hardmax')
    %hardmax
        r = rand;
        if r < mdp.eps && strcmpi(mdp.run_type,'learn')
           a_index = randi(numel(mdp.A),1,mdp.MAS);
        else
            [val, a_index] = max(q,[],1);
        end
    elseif strcmpi(mdp.action_type,'softmax')
    %softmax, not working for MAS
        distr = cumsum(exp(q/mdp.tau),1);
        r = rand(1,mdp.MAS).*distr(end,:);
        logic = repmat(r,numel(mdp.A),1) < distr;
        a_index = zeros(1,mdp.MAS);
        for i = 1:mdp.MAS
            a_index(i) = find(logic(:,i) ~= 0,1,'first');
        end
    end
%     a = a*bc.beta;

    if strcmpi(mdp.resource_alloc,'unif')
        alloc = bc.beta/max(mdp.m,mdp.MAS);
    elseif strcmpi(mdp.resource_alloc,'dir')
        alloc = bc.beta*drchrnd(sigm(mean(q,1)+1),1);
    end

    a = [mdp.A(:,a_index)'.*alloc'; zeros(bc.n-max(mdp.m,mdp.MAS),1); a_index'];
    %updating states only depend on the first bc.n elements of a, we can
    %use everything after that to encode information that might be useful
    
end