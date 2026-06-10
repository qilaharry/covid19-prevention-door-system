function covid_door_gui()
    fis = covid_create_mamfis();  % Get the mamfis object

    % Get user input
    prompt = {'Enter Body Temperature (°F):', 'Enter Mask Compliance (0-8):'};
    dlgtitle = 'COVID-19 Prevention Door System Inputs';
    dims = [1 35];
    definput = {'',''};  % Empty input fields
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    if isempty(answer), return; end  % User canceled

    bodyTemp = str2double(answer{1});
    maskComp = str2double(answer{2});
    input = [bodyTemp maskComp];

    % === 1. Fuzzification Graphs ===
    plotFuzzification(fis, bodyTemp, maskComp);

    % === 2. Rule Evaluation ===
    fprintf('\n--- Rule Evaluation ---\n');
    ruleStrengths = zeros(1, length(fis.Rules));

    for i = 1:length(fis.Rules)
        rule = fis.Rules(i);
        mf1 = fis.Inputs(1).MembershipFunctions(rule.Antecedent(1));
        mf2 = fis.Inputs(2).MembershipFunctions(rule.Antecedent(2));

        mu1 = evalmf(bodyTemp, mf1.Parameters, mf1.Type);
        mu2 = evalmf(maskComp, mf2.Parameters, mf2.Type);

        if rule.Connection == 1  % AND
            ruleStrength = min(mu1, mu2);
        else  % OR
            ruleStrength = max(mu1, mu2);
        end

        ruleStrengths(i) = ruleStrength;

        if ruleStrength > 0
            fprintf('Rule %d fired (%.2f)\n', i, ruleStrength);
        end
    end

    % === 3. Aggregation + Defuzzification ===
    output = evalfis(fis, input);
    plotAggregation(fis, ruleStrengths, output);

    fprintf('\nFinal Output = %.2f → Door is %s\n', output, ternary(output >= 0.5, 'OPEN', 'CLOSE'));
end

% ======================================================
function plotFuzzification(fis, bodyTemp, maskComp)
    tempMFs = fis.Inputs(1).MembershipFunctions;
    maskMFs = fis.Inputs(2).MembershipFunctions;

    x1 = linspace(97, 101, 1000);
    x2 = linspace(0, 8, 1000);

    % Body Temp
    figure('Name','Fuzzification - Body Temperature');
    hold on; grid on;
    title(sprintf('Body Temperature = %.1f°F', bodyTemp));
    xlabel('Body Temp (°F)'); ylabel('Membership Degree');

    for i = 1:length(tempMFs)
        y = evalmf(x1, tempMFs(i).Parameters, tempMFs(i).Type);
        mu = evalmf(bodyTemp, tempMFs(i).Parameters, tempMFs(i).Type);
        plot(x1, y, 'LineWidth',1.5, 'DisplayName', tempMFs(i).Name);

        if mu > 0
            plot(bodyTemp, mu, 'ro');
            text(bodyTemp + 0.05, mu, sprintf('μ = %.2f', mu));
            plot([min(x1), bodyTemp], [mu mu], '--r', 'LineWidth', 1);
        end
    end
    plot([bodyTemp bodyTemp], [0 1], '--r', 'LineWidth', 1.5);
    legend('Location','best');
    ylim([0 1.1]); hold off;

    % Mask Compliance
    figure('Name','Fuzzification - Mask Compliance');
    hold on; grid on;
    title(sprintf('Mask Compliance = %.1f', maskComp));
    xlabel('Mask Count'); ylabel('Membership Degree');

    for i = 1:length(maskMFs)
        y2 = evalmf(x2, maskMFs(i).Parameters, maskMFs(i).Type);
        mu2 = evalmf(maskComp, maskMFs(i).Parameters, maskMFs(i).Type);
        plot(x2, y2, 'LineWidth',1.5, 'DisplayName', maskMFs(i).Name);

        if mu2 > 0
            plot(maskComp, mu2, 'ro');
            text(maskComp + 0.1, mu2, sprintf('μ = %.2f', mu2));
            plot([min(x2), maskComp], [mu2 mu2], '--r', 'LineWidth', 1);
        end
    end
    plot([maskComp maskComp], [0 1], '--r', 'LineWidth', 1.5);
    legend('Location','best');
    ylim([0 1.1]); hold off;
end

% ======================================================
function plotAggregation(fis, ruleStrengths, outputValue)
    outputMFs = fis.Outputs(1).MembershipFunctions;
    x = linspace(0, 1, 1000);

    figure('Name','Aggregation and Defuzzification');
    hold on; grid on;
    xlabel('Door Output'); ylabel('Membership Degree');
    
    for i = 1:length(ruleStrengths)
        if ruleStrengths(i) > 0
            rule = fis.Rules(i);
            mfIdx = rule.Consequent(1);
            mf = outputMFs(mfIdx);
            y = evalmf(x, mf.Parameters, mf.Type);
            plot(x, min(y, ruleStrengths(i)), 'LineWidth', 1.5, ...
                'DisplayName', sprintf('Rule %d (%s)', i, mf.Name));
        end
    end

    plot([outputValue outputValue], [0 1], 'k--', 'LineWidth', 2);
    text(outputValue + 0.02, 0.9, sprintf('Output = %.2f', outputValue));
    legend('Location','best');
    ylim([0 1.1]); hold off;
end




% ======================================================
function result = ternary(cond, a, b)
    if cond
        result = a;
    else
        result = b;
    end
end
