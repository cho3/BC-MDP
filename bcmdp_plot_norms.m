%plot the history of the weight vectors
%requires norms function from cvx
%todo: how to plot norms of vectors given whatever structure i decide on
%in save_check.m

function bcmdp_plot_norms(history,bc,mdp)

    w = history.Ws;
    fields = fieldnames(w);
    num_vec = numel(fields);
    
    for i = 1:num_vec
        subplot(num_vec+1,1,i);
        name = fields{i};
        v = w.(name);
        for j = 1:size(v,1)
            plot(v(j,:),'Color',0.25+0.5*rand(3,1));
            xlabel('Time Steps');
            ylabel(['||',name,'||']);
            hold on
        end
        hold off
    end
    
    %plot total reward per episode as a means of graphically seeing if
    %we're improving
    
    subplot(num_vec+1,1,num_vec+1)
    Rs = zeros(mdp.n_episodes,1);
    for ep = 1:mdp.n_episodes
        Rs(ep) = sum(history.Rs{ep});
    end
    plot(Rs,'x');
    hold on
    plot(moving_average(Rs,100));
    %a more useful metric might be the windowed average total reward over
    %time
    hold off
    xlabel('Episode');
    ylabel('Total Reward per Episode, R');
    
end