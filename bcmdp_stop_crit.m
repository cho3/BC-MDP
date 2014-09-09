%bcmdp_stop_crit.m
%return true/false if everything is within some distance of the goal
function isEnd = bcmdp_stop_crit(s,bc,mdp)
    eps = mdp.stop_thresh;
    goal = mdp.goal;
    isEnd = sum(abs(s-goal) <= eps) == bc.n;
end