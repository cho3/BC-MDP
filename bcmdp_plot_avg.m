%bcmdp_plot_avg.m
%plot average values over several runs of learning (e.g. avg reward/time
%step)

function Rs = bcmdp_plot_avg(histories,bc,mdp)
    %right now only handling Rs
    num_runs = numel(histories);
    Rs = zeros(num_runs,mdp.n_episodes);
    first_fail = mdp.n_episodes;
    for i = 1:num_runs
        history = histories{i};
        for j = 1:numel(history.Rs)
            Rs(i,j) = sum(history.Rs{j});
        end
        first_fail = min(first_fail,numel(history.Rs));
    end
    Rs_ = mean(Rs,1);
    plot(Rs_(1:first_fail));
    xlabel('Episode'); ylabel('Average Total Reward');
    title(['Total Reward Averaged over ' int2str(num_runs) ' Runs']);
    
end