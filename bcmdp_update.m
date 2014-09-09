%bcmdp_update.m
%update the weights somehow using some kind of learning rule (e.g. SARSA,
%Q, etc...)
function w = bcmdp_update(s,a,r,s_,a_,w,phi,phi_,bc,mdp)
    %learning rule
    
    if strcmpi(mdp.learning_rule,'q') || strcmpi(mdp.learning_rule,'sarsa')
        %assume we know whatever index of action we took
        for k = 1:mdp.MAS
        a_index = a(bc.n+k);
        a_index_ = a_(bc.n+k);
        q = w.Wa(:,a_index)'*phi(:,k);
        if strcmpi(mdp.learning_rule,'q')
            q_ = max(w.Wa'*phi_(:,k));
        else
            q_ = w.Wa(:,a_index_)'*phi_(:,k);
        end
        %td error
        del = r - w.r_avg + mdp.gamma*q_ - q;
        %update average reward
        if mdp.alpha_r > 0
            %if using r_avg to encode relative rewards:
            if w.step == 0
                w.r_avg = r;
            else
                w.r_avg = (w.step/(w.step+1))*w.r_avg + (1/(w.step+1))*r;
            end
            w.step = w.step + 1;
            %if using average reward as trace:
%             w.r_avg = w.r_avg + mdp.alpha_r*del;
        end
        %update eligility trace, which is a property of the learning rule
        if mdp.lambda > 0
            %change w.e to a stacked representation, e(s,a) (as opposed to
            %just e(s) as it is now
            w.e = mdp.gamma*mdp.lambda*w.e;
            if strcmpi(mdp.trace_type,'accumulating')
                w.e(1+(a(end)-1)*size(phi,1):a(end)*size(phi,1),k) = ...
                    w.e(1+(a(end)-1)*size(phi,1):a(end)*size(phi,1)) + phi(:,k);
            elseif strcmpi(mdp.trace_type,'replacing')
                %still need to do this one
                w.e(1+(a(end)-1)*size(phi,1):a(end)*size(phi,1),k) = ...
                    bsxfun(@max,w.e(1+(a(end)-1)*size(phi,1):a(end)*size(phi,1),k),phi(:,k));
            end
        end
        w.Wa(:,a_index) = w.Wa(:,a_index) + ...
            mdp.alpha_w*del*w.e(1+(a(end)-1)*size(phi,1):a(end)*size(phi,1),k);
        end
    elseif strcmpi(mdp.learning_rule,'gtd2') ||strcmpi(mdp.learning_rule,'tdc')
        a_index = a(bc.n+1);
        a_index_ = a_(bc.n+1);
        q = w.Wa(:,a_index)'*phi(:,1);
        q_ = w.Wa(:,a_index_)'*phi_(:,1);
        %td error
        del = r - w.r_avg + mdp.gamma*q_ - q;
        if strcmpi(mdp.learning_rule,'gtd2')
            w.Wa(:,a_index) = w.Wa(:,a_index) + mdp.alpha_w*(phi-mdp.gamma*phi_)...
                *(w.u'*phi);
        elseif strcmpi(mdp.learning_rule,'tdc')
            w.Wa(:,a_index) = w.Wa(:,a_index) + mdp.alpha_w*del*phi - ...
                mdp.alpha_w*mdp.gamma*phi_*(phi'*w.u);
        end
        
        w.u = w.u + mdp.alpha_u*(del-phi'*w.u)*phi;
        
    elseif strcmpi(mdp.learning_rule,'copdac-gq')
        
    end
    
    %todo: other learning methods
end