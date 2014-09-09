%bcmdp_featureFunctionBin.m
%the discretization of features into bins, independent agents
%i think there is a flaw in how this is done.. there's no reference to
%where everything is relative to the goal state...
function phi = bcmdp_featureFunctionBin(s,k,bc,mdp)
    
    num_bins = mdp.n_bins*2+1;
    %masks relative to the actors
%     lower = [-1.001,linspace(-bc.eps_l,-mdp.del,mdp.n_bins),...
%         linspace(mdp.del,bc.eps_r,mdp.n_bins)];
%     upper = [linspace(-bc.eps_l,-mdp.del,mdp.n_bins),...
%         linspace(mdp.del,bc.eps_r,mdp.n_bins),1];
    %equal spacing
    rel_mask = linspace(-1.001,1,2*mdp.n_bins+2);
    upper = rel_mask(2:end);
    lower = rel_mask(1:end-1);
    %absolute masks for the actor
%     abs_mask = [linspace(-0.001,mdp.goal-mdp.del/4,mdp.n_bins+1),...
%         linspace(mdp.goal+mdp.del/4,1,mdp.n_bins+1)];
    %equal spacing
    abs_mask = linspace(-0.001,1,2*mdp.n_bins+2);
    abs_lower = abs_mask(1:end-1);
    abs_upper = abs_mask(2:end);

    if strcmpi(mdp.feature_type,'explicit')
        phi = zeros(bc.n*mdp.m*num_bins,1);
        %build upper and lower bound mask for bins, build relative vectors
        %for each agent, use & or something
        %the first m agents are controlled
        for j = 1:mdp.m
            if mdp.m == 1 && mdp.MAS > 0
                j = k;
            end
            s_rel = s-s(j);
            for i = 1:bc.n
                phi(1+bc.n*num_bins*(j-1)+num_bins*(i-1):bc.n*num_bins*(j-1)+num_bins*i)...
                    = s_rel(i) > lower & s_rel(i) <= upper;
            end
        end
        
    elseif strcmpi(mdp.feature_type,'hist')
        %use same upper/lower structure, but focused around the goal state
        phi = zeros(mdp.m*num_bins*num_bins,1);
        
        for j = 1:mdp.m
            if mdp.m ~= 1 || mdp.MAS <= 1
                k = j;
            end
            s_rel = s-s(k);
            %what bin actor j falls into
            abs_bin = find((s(k)>=abs_lower)&(s(k)<=abs_upper)~=0,1);
            for i = 1:bc.n
                phi(1+((j-1)+(abs_bin-1))*num_bins:((j)+(abs_bin-1))*num_bins)...
                    = phi(1+((j-1)+(abs_bin-1))*num_bins:((j)+(abs_bin-1))*num_bins)...
                    + (s_rel(i) > lower' & s_rel(i) <= upper');
            end
        end
        
        if strcmpi(mdp.feature_scaling,'binary')
            phi = bsxfun(@min,phi,1);
        elseif strcmpi(mdp.feature_scaling,'sqrt')
            phi = sqrt(phi);
        end
            
    end
    
end