function s0 = bcmdp_init_s(episode,bc,mdp)
    if strcmpi(bc.init,'rand')
        s0 = rand(bc.n,1);
    elseif strcmpi(bc.init,'unif')
        s0 = linspace(0,1,bc.n)';
    elseif strcmpi(bc.init,'fixrand')
        s0 = mdp.s0(:,episode);
    end
end