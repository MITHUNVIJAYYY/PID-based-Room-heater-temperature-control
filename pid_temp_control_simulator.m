function pid_temp_control_with_comparison()
    % PID Temperature Control System with Auto-Comparison Feature
    % Tests multiple PID sets and categorizes them as Perfect/Good/OK/Bad

    close all;
    clc;

    %=================== GUI SETUP ================================
    fig = figure('Name', 'PID Control Simulator with Comparison', ...
        'NumberTitle', 'off', ...
        'Position', [50 50 1400 700], ...
        'Color', [0.95 0.95 0.95], ...
        'MenuBar', 'none', ...
        'Toolbar', 'none');

    % Control Panel
    ctrl_panel = uipanel('Parent', fig, ...
        'Title', 'Control Panel', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Position', [0.01 0.3 0.17 0.68], ...
        'BackgroundColor', [0.95 0.95 0.95]);

    % Graph Panel
    graph_panel = uipanel('Parent', fig, ...
        'Title', 'Live Monitoring', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Position', [0.19 0.02 0.40 0.96], ...
        'BackgroundColor', [1 1 1]);

    % Comparison Table Panel
    comparison_panel = uipanel('Parent', fig, ...
        'Title', 'PID Tuning Comparison Results', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Position', [0.60 0.35 0.39 0.63], ...
        'BackgroundColor', [0.95 0.95 0.95]);

    % Data Panel
    data_panel = uipanel('Parent', fig, ...
        'Title', 'System Console', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Position', [0.60 0.02 0.39 0.32], ...
        'BackgroundColor', [0.95 0.95 0.95]);

    % Info Panel
    info_panel = uipanel('Parent', fig, ...
        'Title', 'Current Status', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Position', [0.01 0.02 0.17 0.26], ...
        'BackgroundColor', [0.95 0.95 0.95]);

    %=================== CONTROL ELEMENTS =========================
    % Setpoint Temperature
    uicontrol('Parent', ctrl_panel, ...
        'Style', 'text', ...
        'String', 'Target Temperature (°C):', ...
        'Position', [10 430 140 20], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 0.95]);

    temp_box = uicontrol('Parent', ctrl_panel, ...
        'Style', 'edit', ...
        'String', '50', ...
        'Position', [10 408 140 25], ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [1 1 0.8]);

    % P Gain
    uicontrol('Parent', ctrl_panel, ...
        'Style', 'text', ...
        'String', 'P Gain (Proportional):', ...
        'Position', [10 375 140 20], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 0.95]);

    p_box = uicontrol('Parent', ctrl_panel, ...
        'Style', 'edit', ...
        'String', '2.0', ...
        'Position', [10 353 140 25], ...
        'FontSize', 10);

    % I Gain
    uicontrol('Parent', ctrl_panel, ...
        'Style', 'text', ...
        'String', 'I Gain (Integral):', ...
        'Position', [10 320 140 20], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 0.95]);

    i_box = uicontrol('Parent', ctrl_panel, ...
        'Style', 'edit', ...
        'String', '0.15', ...
        'Position', [10 298 140 25], ...
        'FontSize', 10);

    % D Gain
    uicontrol('Parent', ctrl_panel, ...
        'Style', 'text', ...
        'String', 'D Gain (Derivative):', ...
        'Position', [10 265 140 20], ...
        'FontSize', 8, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 0.95]);

    d_box = uicontrol('Parent', ctrl_panel, ...
        'Style', 'edit', ...
        'String', '0.08', ...
        'Position', [10 243 140 25], ...
        'FontSize', 10);

    % Buttons
    start_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', 'START', ...
        'Position', [10 195 65 30], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.8 0.2], ...
        'ForegroundColor', 'white', ...
        'Callback', @start_callback);

    stop_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', 'STOP', ...
        'Position', [85 195 65 30], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.9 0.3 0.2], ...
        'ForegroundColor', 'white', ...
        'Enable', 'off', ...
        'Callback', @stop_callback);

    reset_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', 'RESET', ...
        'Position', [10 155 140 30], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.3 0.5 0.9], ...
        'ForegroundColor', 'white', ...
        'Callback', @reset_callback);

    % NEW: Compare PID Sets Button
    compare_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', '🔬 COMPARE PID SETS', ...
        'Position', [10 110 140 35], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.9 0.6 0.2], ...
        'ForegroundColor', 'white', ...
        'Callback', @compare_callback);

    % Load Best PID Button
    load_best_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', '⭐ Load Best PID', ...
        'Position', [10 70 140 30], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.8 0.4 0.8], ...
        'ForegroundColor', 'white', ...
        'Enable', 'off', ...
        'Callback', @load_best_callback);

    exit_btn = uicontrol('Parent', ctrl_panel, ...
        'Style', 'pushbutton', ...
        'String', 'EXIT', ...
        'Position', [10 30 140 30], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.5 0.5 0.5], ...
        'ForegroundColor', 'white', ...
        'Callback', @(~,~) close(fig));

    % Console
    console_box = uicontrol('Parent', data_panel, ...
        'Style', 'listbox', ...
        'Position', [10 10 530 195], ...
        'FontSize', 8, ...
        'FontName', 'Courier New');

    % Info Display
    info_text = uicontrol('Parent', info_panel, ...
        'Style', 'text', ...
        'String', sprintf('Temp: -- °C\nError: -- °C\nPWM: -- %%\nTime: 0.0 s'), ...
        'Position', [10 10 140 150], ...
        'FontSize', 9, ...
        'FontName', 'Courier New', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95 0.95 0.95]);

    %=================== COMPARISON TABLE =========================
    % Create table to display results
    column_names = {'Set', 'Kp', 'Ki', 'Kd', 'Overshoot%', 'SettleTime', 'IAE', 'Score', 'Category'};
    column_format = {'char', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'char'};

    comparison_table = uitable('Parent', comparison_panel, ...
        'Position', [10 10 530 400], ...
        'ColumnName', column_names, ...
        'ColumnFormat', column_format, ...
        'ColumnWidth', {40, 45, 45, 45, 80, 75, 60, 55, 70}, ...
        'RowName', [], ...
        'FontSize', 9, ...
        'Data', cell(0, 9));

    %=================== GRAPHS ===================================
    % Temperature Graph
    ax1 = axes('Parent', graph_panel, ...
        'Position', [0.12 0.57 0.84 0.38]);
    hold(ax1, 'on');
    grid(ax1, 'on');
    title(ax1, 'Temperature Response', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax1, 'Time (seconds)', 'FontSize', 9);
    ylabel(ax1, 'Temperature (°C)', 'FontSize', 9);
    temp_line = plot(ax1, 0, 25, 'b-', 'LineWidth', 2);
    setpoint_line = plot(ax1, 0, 50, 'r--', 'LineWidth', 1.5);
    legend(ax1, {'Actual Temperature', 'Setpoint'}, 'Location', 'southeast');
    xlim(ax1, [0 10]);
    ylim(ax1, [0 100]);

    % PWM Graph
    ax2 = axes('Parent', graph_panel, ...
        'Position', [0.12 0.10 0.84 0.38]);
    hold(ax2, 'on');
    grid(ax2, 'on');
    title(ax2, 'Control Signal (PWM)', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax2, 'Time (seconds)', 'FontSize', 9);
    ylabel(ax2, 'PWM Output (%)', 'FontSize', 9);
    pwm_line = plot(ax2, 0, 0, 'm-', 'LineWidth', 2);
    xlim(ax2, [0 10]);
    ylim(ax2, [0 100]);

    %=================== VARIABLES ================================
    running = false;
    Ts = 0.2;
    max_samples = 500;

    time_data = [];
    temp_data = [];
    pwm_data = [];

    integral_error = 0;
    prev_error = 0;
    current_temp = 25;
    ambient_temp = 25;
    prev_setpoint = 0;

    % Store comparison results
    comparison_results = [];
    best_pid = [];

    %=================== PID TEST SETS ============================
    % Correct: each row is {Kp, Ki, Kd, 'Description'}
    pid_test_sets = {
        1.0, 0.05, 0.02, 'Very Conservative';
        1.5, 0.10, 0.05, 'Conservative';
        2.0, 0.15, 0.08, 'Balanced (Default)';
        2.5, 0.18, 0.10, 'Moderate';
        3.0, 0.20, 0.12, 'Aggressive';
        4.0, 0.25, 0.15, 'Very Aggressive';
        2.0, 0.30, 0.05, 'High Integral';
        3.5, 0.10, 0.20, 'High Derivative';
        5.0, 0.35, 0.18, 'Extreme';
        1.8, 0.12, 0.10, 'Optimized #1';
    };

    %=================== CALLBACKS ================================
    function start_callback(~, ~)
        running = true;
        set(start_btn, 'Enable', 'off');
        set(stop_btn, 'Enable', 'on');
        set(temp_box, 'Enable', 'on');
        add_console('>>> System STARTED');

        time_data = [];
        temp_data = [];
        pwm_data = [];
        integral_error = 0;
        prev_error = 0;
        current_temp = ambient_temp;
        prev_setpoint = str2double(get(temp_box, 'String'));

        start_time = tic;
        while running
            current_time = toc(start_time);

            setpoint = str2double(get(temp_box, 'String'));
            Kp = str2double(get(p_box, 'String'));
            Ki = str2double(get(i_box, 'String'));
            Kd = str2double(get(d_box, 'String'));

            if isnan(setpoint) || isnan(Kp) || isnan(Ki) || isnan(Kd)
                add_console('ERROR: Invalid parameter!');
                stop_callback([], []);
                return;
            end

            if abs(setpoint - prev_setpoint) > 0.1
                add_console(sprintf('[%.1fs] Setpoint: %.1f°C → %.1f°C', ...
                    current_time, prev_setpoint, setpoint));
                prev_setpoint = setpoint;
            end

            % PID Controller
            error = setpoint - current_temp;
            integral_error = integral_error + error * Ts;
            derivative = (error - prev_error) / Ts;
            control_signal = Kp * error + Ki * integral_error + Kd * derivative;
            prev_error = error;

            % Thermal system simulation
            heater_gain = 0.18;
            thermal_loss = 0.035;
            noise = randn * 0.1;

            current_temp = current_temp + Ts * ( ...
                heater_gain * control_signal - ...
                thermal_loss * (current_temp - ambient_temp)) + noise;

            current_temp = max(min(current_temp, 100), ambient_temp);
            pwm = max(min(control_signal, 100), 0);

            time_data = [time_data current_time];
            temp_data = [temp_data current_temp];
            pwm_data = [pwm_data pwm];

            if length(time_data) > max_samples
                time_data = time_data(end-max_samples+1:end);
                temp_data = temp_data(end-max_samples+1:end);
                pwm_data = pwm_data(end-max_samples+1:end);
            end

            set(temp_line, 'XData', time_data, 'YData', temp_data);
            set(setpoint_line, 'XData', time_data, 'YData', ones(size(time_data))*setpoint);
            set(pwm_line, 'XData', time_data, 'YData', pwm_data);

            if current_time > 10
                xlim(ax1, [current_time-10, current_time]);
                xlim(ax2, [current_time-10, current_time]);
            end

            info_str = sprintf('Temp: %.2f °C\nError: %.2f °C\nPWM: %.1f %%\nTime: %.1f s', ...
                current_temp, error, pwm, current_time);
            set(info_text, 'String', info_str);

            drawnow limitrate;
            pause(Ts);

            if ~ishandle(fig)
                return;
            end
        end
    end

    function stop_callback(~, ~)
        running = false;
        set(start_btn, 'Enable', 'on');
        set(stop_btn, 'Enable', 'off');
        set(temp_box, 'Enable', 'on');
        add_console('>>> System STOPPED');
    end

    function reset_callback(~, ~)
        if running
            stop_callback([], []);
        end

        time_data = [];
        temp_data = [];
        pwm_data = [];
        integral_error = 0;
        prev_error = 0;
        current_temp = ambient_temp;

        set(temp_line, 'XData', 0, 'YData', 25);
        set(setpoint_line, 'XData', 0, 'YData', str2double(get(temp_box, 'String')));
        set(pwm_line, 'XData', 0, 'YData', 0);
        xlim(ax1, [0 10]);
        xlim(ax2, [0 10]);

        set(info_text, 'String', sprintf('Temp: -- °C\nError: -- °C\nPWM: -- %%\nTime: 0.0 s'));
        set(console_box, 'String', {});
        add_console('>>> System RESET');
    end

    %=================== COMPARISON FUNCTION ======================
    function compare_callback(~, ~)
        add_console('>>> Starting PID Comparison...');
        add_console('Testing multiple PID sets...');

        set(compare_btn, 'Enable', 'off');
        drawnow;

        comparison_results = [];
        setpoint = str2double(get(temp_box, 'String'));

        for i = 1:size(pid_test_sets, 1)
            Kp_test = pid_test_sets{i, 1};
            Ki_test = pid_test_sets{i, 2};
            Kd_test = pid_test_sets{i, 3};
            description = pid_test_sets{i, 4};

            add_console(sprintf('Testing Set %d: %s...', i, description));

            % Run simulation for this PID set
            [metrics, success] = simulate_pid_set(Kp_test, Ki_test, Kd_test, setpoint);

            if success
                % Calculate overall score (0-100)
                score = calculate_score(metrics);

                % Categorize based on score
                if score >= 85
                    category = '⭐ Perfect';
                elseif score >= 70
                    category = '✓ Good';
                elseif score >= 50
                    category = '~ OK';
                else
                    category = '✗ Bad';
                end

                % Store results
                result = struct();
                result.set_num = i;
                result.Kp = Kp_test;
                result.Ki = Ki_test;
                result.Kd = Kd_test;
                result.overshoot = metrics.overshoot;
                result.settling_time = metrics.settling_time;
                result.iae = metrics.iae;
                result.score = score;
                result.category = category;
                result.description = description;

                comparison_results = [comparison_results; result];
            else
                add_console(sprintf('Set %d: Simulation failed (unstable).', i));
            end
        end

        if isempty(comparison_results)
            add_console('No successful PID sets found.');
            set(compare_btn, 'Enable', 'on');
            return;
        end

        % Sort by score (best first)
        [~, sort_idx] = sort([comparison_results.score], 'descend');
        comparison_results = comparison_results(sort_idx);

        % Update table
        update_comparison_table();

        % Store best PID
        best_pid = comparison_results(1);
        set(load_best_btn, 'Enable', 'on');

        add_console(sprintf('>>> Comparison Complete!'));
        add_console(sprintf('Best: Set %d (Score: %.1f)', best_pid.set_num, best_pid.score));
        set(compare_btn, 'Enable', 'on');
    end

    function [metrics, success] = simulate_pid_set(Kp, Ki, Kd, setpoint)
        % Run a quick simulation (30 seconds) with given PID parameters
        success = true;

        sim_time = 0;
        sim_duration = 30;
        temp = 25;
        int_error = 0;
        prev_err = 0;

        temp_history = [];
        time_history = [];

        while sim_time < sim_duration
            error = setpoint - temp;
            int_error = int_error + error * Ts;
            deriv = (error - prev_err) / Ts;
            control = Kp * error + Ki * int_error + Kd * deriv;
            prev_err = error;

            % Same thermal model
            heater_gain = 0.18;
            thermal_loss = 0.035;
            temp = temp + Ts * (heater_gain * control - thermal_loss * (temp - 25));
            temp = max(min(temp, 100), 25);

            temp_history = [temp_history temp];
            time_history = [time_history sim_time];

            sim_time = sim_time + Ts;

            % Check for instability
            if temp > 150 || isnan(temp) || ~isfinite(temp)
                success = false;
                break;
            end
        end

        if success
            % Calculate metrics
            metrics = calculate_metrics(time_history, temp_history, setpoint);
        else
            metrics = struct('overshoot', 999, 'settling_time', 999, 'iae', 999);
        end
    end

    function metrics = calculate_metrics(time, temp, setpoint)
        % Calculate performance metrics

        % 1. Overshoot
        max_temp = max(temp);
        overshoot = ((max_temp - setpoint) / setpoint) * 100;
        overshoot = max(overshoot, 0);  % No negative overshoot

        % 2. Settling Time (within 2% of setpoint)
        tolerance = 0.02 * setpoint;
        settled = abs(temp - setpoint) < tolerance;
        settle_idx = find(settled, 1);
        if ~isempty(settle_idx) && settle_idx < length(time) - 10
            settling_time = time(settle_idx);
        else
            settling_time = 999;  % Never settled
        end

        % 3. IAE (Integral of Absolute Error)
        iae = sum(abs(temp - setpoint)) * Ts;

        metrics.overshoot = overshoot;
        metrics.settling_time = settling_time;
        metrics.iae = iae;
    end

    function score = calculate_score(metrics)
        % Calculate overall score (0-100) based on weighted metrics

        % Scoring weights
        w_overshoot = 0.35;
        w_settling = 0.35;
        w_iae = 0.30;

        % Overshoot score (100 = no overshoot, 0 = 20%+ overshoot)
        overshoot_score = max(0, 100 - metrics.overshoot * 5);

        % Settling time score (100 = <5s, 0 = >30s)
        if metrics.settling_time < 5
            settling_score = 100;
        elseif metrics.settling_time < 30
            settling_score = 100 - (metrics.settling_time - 5) * 4;
        else
            settling_score = 0;
        end

        % IAE score (100 = <50, 0 = >500)
        if metrics.iae < 50
            iae_score = 100;
        elseif metrics.iae < 500
            iae_score = 100 - (metrics.iae - 50) / 4.5;
        else
            iae_score = 0;
        end

        % Weighted total
        score = w_overshoot * overshoot_score + ...
                w_settling * settling_score + ...
                w_iae * iae_score;

        score = max(0, min(100, score));  % Clamp to 0-100
    end

    function update_comparison_table()
        % Populate table with results
        table_data = {};

        for i = 1:length(comparison_results)
            r = comparison_results(i);
            table_data{i, 1} = sprintf('#%d', r.set_num);
            table_data{i, 2} = r.Kp;
            table_data{i, 3} = r.Ki;
            table_data{i, 4} = r.Kd;
            table_data{i, 5} = round(r.overshoot, 1);
            table_data{i, 6} = round(r.settling_time, 2);
            table_data{i, 7} = round(r.iae, 1);
            table_data{i, 8} = round(r.score, 1);
            table_data{i, 9} = r.category;
        end

        set(comparison_table, 'Data', table_data);
    end

    function load_best_callback(~, ~)
        if ~isempty(best_pid)
            set(p_box, 'String', num2str(best_pid.Kp));
            set(i_box, 'String', num2str(best_pid.Ki));
            set(d_box, 'String', num2str(best_pid.Kd));
            add_console(sprintf('>>> Loaded Best PID: Set %d', best_pid.set_num));
            add_console(sprintf('Kp=%.2f, Ki=%.2f, Kd=%.2f', ...
                best_pid.Kp, best_pid.Ki, best_pid.Kd));
        end
    end

    function add_console(msg)
        current_msgs = get(console_box, 'String');
        if isempty(current_msgs)
            new_msgs = {msg};
        else
            new_msgs = [current_msgs; {msg}];
            if length(new_msgs) > 50
                new_msgs = new_msgs(end-49:end);
            end
        end
        set(console_box, 'String', new_msgs);
        set(console_box, 'Value', length(new_msgs));
        drawnow;
    end

    % Initial messages
    add_console('========================================');
    add_console('PID Control with Auto-Comparison v2.0');
    add_console('========================================');
    add_console('');
    add_console('NEW: Click "COMPARE PID SETS" to test');
    add_console('multiple PID configurations!');
    add_console('');
    add_console('Results categorized as:');
    add_console('  ⭐ Perfect (85-100 score)');
    add_console('  ✓ Good (70-84 score)');
    add_console('  ~ OK (50-69 score)');
    add_console('  ✗ Bad (<50 score)');
    add_console('');
    add_console('Ready to start...');
end
