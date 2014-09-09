%plots the history of a given episode

function bcmdp_plot_episode(history,episode,bc,mdp)
    %history will only have Xs and As and Rs...
    X = history.Xs{episode};
    A = history.As{episode};
    R = history.Rs{episode};
    
    if strcmpi(mdp.run_type,'dynamics')
        Xdiff_ = abs(X(:,6:end)-X(:,1:end-5));
        Xdiff = Xdiff_'*ones(bc.n,1);
        j_end = find(Xdiff == 0,1,'first');
        for i = 1:bc.n
            %distinguish controlled agents
            if i <= mdp.m
                plot(X(i,1:j_end),':','Color',0.25+0.5*rand(3,1));
            else
                plot(X(i,1:j_end),'Color',0.25+0.5*rand(3,1));
            end
            hold on
        end
        title('Last Run');
        xlabel('Time Steps');
        ylabel('Opinion State, s');
        hold off
    else
    %     hold on
        if strcmpi(mdp.reward_fn,'const')
            j_end = find(R == 1,1,'first');
        else
            j_end = find(R == 0,1,'first');
        end
        if isempty(j_end)
            j_end = bc.T;
        end
        subplot(3,1,1);
        for i = 1:bc.n
            %distinguish controlled agents
            if i <= mdp.m
                plot(X(i,1:j_end),':','Color',0.25+0.5*rand(3,1));
            else
                plot(X(i,1:j_end),'Color',0.25+0.5*rand(3,1));
            end
            hold on
        end
        title('Last Run');
        xlabel('Time Steps');
        ylabel('Opinion State, s');
        hold off

    %     hold on
        subplot(3,1,2);
        for j = 1:bc.n
            plot(A(j,1:j_end),'Color',0.25+0.5*rand(3,1));
            hold on
        end
        xlabel('Time Steps');
        ylabel('Action (Bribe), a');
        hold off

        subplot(3,1,3);
        plot(R(1:j_end));
        xlabel('Time Steps');
        ylabel('Rewards');        
    end
    
end