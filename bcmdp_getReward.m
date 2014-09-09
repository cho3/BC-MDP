%bcmdp_getReward.m
%a switch that handles what reward structure to use
function r = bcmdp_getReward(s_,a,bc,mdp)
    %keeping things in terms of costs is good, since 0 is best, and early
    %stopping just assumes we cruise afterwards (even thought the policies
    %are such that we don't actually cruise.
    %can have regularization for a if using policy gradient or something
    goal = mdp.goal;
    type = mdp.reward_fn;
    %or use switch
    if strcmpi('L1',type)
        r = -norm(s_-goal,1)-mdp.J(1)*(max(s_)-min(s_))-mdp.J(2)*var(s_);
    elseif strcmpi('L2',type)
        r = -norm(s_-goal,2)-mdp.J(1)*(max(s_)-min(s_))-mdp.J(2)*var(s_);
    elseif strcmpi('const',type)
        r = -1;
    end
    
    return

end