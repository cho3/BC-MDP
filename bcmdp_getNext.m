function s_new = bcmdp_getNext(s,a,bc)
    %transition dynamics for bounded confidence model
    n = bc.n; %number of agents
    eps_l = bc.eps_l; %left bound
    eps_r = bc.eps_r; %right bound
    p = bc.p; %prob of no msg
    q = bc.q; %prob of wrong msg
    
    %do something to transform a from a projected tuple to full thing
    %%nvm
    %scale a
    %only consider the first n elements which correspond to perturbations
    %on each of the n agents, everything after that is junk/coding/extra
    a = a(1:bc.n,:); 
%     a = a*bc.beta;

    
    %can also use the LL model where they evolve, then bribe, but this
    %makes more sense... (so then it would be s_new = s_new + a, bound...
    s = s + a;
    %check if out of bounds
    s(s>1) = 1;
    s(s<0) = 0;
    
    s_new = zeros(size(s));
    for i = 1:n       
        %no ordered property (MDP/controled)
        a = find(s > s(i) - eps_l);
        b = find(s < s(i) + eps_r);
        m = intersect(a,b);
        
        %add random transitions
        sN = s(m);
        sN = setxor(sN,s(i)); %set aside personal value
        r = rand(numel(sN),1);
        %going to MINUS (out of range) might be estreme-consider rounding
        sN(r < q) = round(sN(r < q));
        
        s_new(i) = mean([sN(r > 1-p); s(i)]);
%         A{t-1}(i,m) = 1;
%         A{t-1}(m,i) = 1;
    end

end