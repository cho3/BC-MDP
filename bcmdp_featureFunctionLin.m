%bcmdp_featureFunctionLin.m
%my attempt to make smarter features
%this will most likely fail miserably
function phi = bcmdp_featureFunctionLin(s,k,bc,mdp)
    phi = zeros(mdp.m*bc.n*4,1);
    
    for i = 1:mdp.m
        if mdp.MAS <=1 
            k = i;
        end
        phi_ = [max(0,s-s(k));max(0,s(k)-s);max(0,s-mdp.goal);max(0,mdp.goal-s)];
        phi(1+(i-1)*4*bc.n:i*bc.n*4) = phi_;
    end
    
    %features: positive distance from agent i
    %       negative distance from agent i
    %       positive distance from goal
    %       negative distance from goal
end