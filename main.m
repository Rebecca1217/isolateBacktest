cd E:\Repository\isolateBacktest
addpath BacktestPlatform_for_futs_v2

% E:\outSample\singleFactorStrategy\testResult里面存储的是用backtestSummary.m把各个策略净值平均得到的
% 这里读取各个策略的交易单，每个策略分别回测一遍用于核对
% 并把所有交易单汇总轧差得到总净值，正常来讲，总净值会比直接平均净值效果好一点

%% 读取所有交易单

% 现货溢价因子交易单
fileFolder = fullfile('Z:\FRL\factorStrategy\spotPremium');
dirOutput = dir(fullfile(fileFolder, '*'));
allFileNames = {dirOutput.name}';

updDate = regexp(allFileNames, '(?<=-)\d+', 'match');
updDate = cellfun(@(x) cell2mat(x), updDate, 'UniformOutput', false);
updDate = max(str2double(updDate));
%% 回测参数
strategyPara.crossType = 'dn';
strategyPara.freqK = 'Dly';
strategyPara.stDate = 20190311;
strategyPara.edDate = updDate;

tradingPara.futDataPath = '\\CJ-LMXUE-DT\futureData_fromWind\priceData_byFut'; %期货主力合约数据路径
tradingPara.PType = 'open';
tradingPara.fixC = 0.0002;
tradingPara.slip = 2;

% spotPremium60
fileNames60 = regexp(allFileNames, 'targetList60.*', 'match');
fileNames60 = fileNames60(cellfun(@(x) ~isempty(x), fileNames60));
fileNames60 = cellfun(@char, fileNames60, 'UniformOutput', false);
for iDate = 1 : length(fileNames60)
    readNameI = ['Z:\FRL\factorStrategy\spotPremium\', fileNames60{iDate}];
    load(readNameI)
    if iDate == 1
        targetListTotalSP60 = targetList60;
    else
        targetListTotalSP60 = vertcat(targetListTotalSP60, targetList60);
    end
end

% [backtestResultSP60, backtestAnalysisSP60] = ...
%     CTABacktest_GeneralPlatform_v2_1(targetListTotalSP60, strategyPara, tradingPara);

% spotPremium90
fileNames90 = regexp(allFileNames, 'targetList90.*', 'match');
fileNames90 = fileNames90(cellfun(@(x) ~isempty(x), fileNames90));
fileNames90 = cellfun(@char, fileNames90, 'UniformOutput', false);

for iDate = 1 : length(fileNames90)
    readNameI = ['Z:\FRL\factorStrategy\spotPremium\', fileNames90{iDate}];
    load(readNameI)
    if iDate == 1
        targetListTotalSP90 = targetList90;
    else
        targetListTotalSP90 = vertcat(targetListTotalSP90, targetList90);
    end
end

% [backtestResultSP90, backtestAnalysisSP90] = ...
%     CTABacktest_GeneralPlatform_v2_1(targetListTotalSP90, strategyPara, tradingPara);

% 仓单因子交易单
fileFolder = fullfile('Z:\FRL\factorStrategy\warrant');
dirOutput = dir(fullfile(fileFolder, '*'));
allFileNames = {dirOutput.name}';

% warrant090
fileNames90 = regexp(allFileNames, 'targetList90.*', 'match');
fileNames90 = fileNames90(cellfun(@(x) ~isempty(x), fileNames90));
fileNames90 = cellfun(@char, fileNames90, 'UniformOutput', false);

for iDate = 1 : length(fileNames90)
    readNameI = ['Z:\FRL\factorStrategy\warrant\', fileNames90{iDate}];
    load(readNameI)
    if iDate == 1
        targetListTotalWT90 = targetList90;
    else
        targetListTotalWT90 = vertcat(targetListTotalWT90, targetList90);
    end
end

% [backtestResultWT90, backtestAnalysisWT90] = ...
%     CTABacktest_GeneralPlatform_v2_1(targetListTotalWT90, strategyPara, tradingPara);

% warrant0250
fileNames250 = regexp(allFileNames, 'targetList250.*', 'match');
fileNames250 = fileNames250(cellfun(@(x) ~isempty(x), fileNames250));
fileNames250 = cellfun(@char, fileNames250, 'UniformOutput', false);

for iDate = 1 : length(fileNames250)
    readNameI = ['Z:\FRL\factorStrategy\warrant\', fileNames250{iDate}];
    load(readNameI)
    if iDate == 1
        targetListTotalWT250 = targetList250;
    else
        targetListTotalWT250 = vertcat(targetListTotalWT250, targetList250);
    end
end

% [backtestResultWT250, backtestAnalysisWT250] = ...
%     CTABacktest_GeneralPlatform_v2_1(targetListTotalWT250, strategyPara, tradingPara);

%% 合成交易单
totalTargetList = vertcat(targetListTotalSP60, targetListTotalSP90, ...
    targetListTotalWT90, targetListTotalWT250);
% 轧差
totalTargetList = varfun(@sum, totalTargetList, 'GroupingVariables', {'date', 'time', 'futCont' 'Mark'});
totalTargetList = totalTargetList(:, {'date', 'time', 'futCont', 'sum_hands', 'sum_targetP', 'sum_targetC', 'Mark'});
totalTargetList.Properties.VariableNames = {'date', 'time', 'futCont', 'Hands', 'TargetP', 'TargetC', 'Mark'};
% 轧差后的结果需要对Mark重新处理  这个和getTargetList中处理还不太一样，因为不需要shift相减从目标持仓转换为交易手数
% 本身就已经是每天需要操作的交易单，也就是前一天-4， 后一天16， 不需要再相减，第二天需要做的是先平4手，再开12手。
% 就是需要对当前轧差后的交易单再做一个“平开”拆分


totalTargetList.Variety = regexp(totalTargetList.futCont, '^[A-Z]+', 'match');
totalTargetListBck = totalTargetList;
totalTargetList.Variety = cellfun(@char, totalTargetList.Variety, 'UniformOutput', false);
totalTargetList = unstack(totalTargetList(:, {'date', 'Variety', 'Hands'}), 'Hands', 'Variety');
% 把开和平分两部分添加标签后再合到一起：
varNames = totalTargetList.Properties.VariableNames;
totalTargetList = array2table([totalTargetList.date, ...
    arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(totalTargetList(:, 2:end)))], ...
    'VariableNames', varNames);

shiftTotalTList = totalTargetList(1:end-1, :);
% 第一行全部都是'开'， 从第二行开始对比

% @2019.03.26 之前有个细节错了，不是跟上一行的符号去对比，而是应该跟上一行未平仓所有手数去对比（需要求和）
remainList = array2table([shiftTotalTList.date, cumsum(table2array(shiftTotalTList(:, 2:end)), 1)], ...
    'VariableNames', totalTargetList.Properties.VariableNames);
% 只“开”：
openLabel = sign(table2array(totalTargetList(2:end, 2:end))) == sign(table2array(remainList(:, 2:end))) | ...
    (table2array(remainList(:, 2:end)) == 0 & table2array(totalTargetList(2:end, 2:end)) ~= 0);
% 只“平”：
evenLabel = sign(table2array(totalTargetList(2:end, 2:end))) ~= sign(table2array(remainList(:, 2:end))) & ...
    abs(table2array(totalTargetList(2:end, 2:end))) <= abs(table2array(remainList(:, 2:end)));
% 先平后开：
multiLabel = sign(table2array(totalTargetList(2:end, 2:end))) ~= sign(table2array(remainList(:, 2:end))) & ...
    abs(table2array(totalTargetList(2:end, 2:end))) > abs(table2array(remainList(:, 2:end))) & ...
    sign(table2array(remainList(:, 2:end))) ~= 0;
% 开，包含只开和先平后开中开的部分
openHands1 = [totalTargetList.date(2:end), openLabel .* table2array(totalTargetList(2:end, 2:end))];
openHands2 = [totalTargetList.date(2:end), multiLabel .* ...
    (table2array(totalTargetList(2:end, 2:end)) + table2array(remainList(:, 2:end)))];
openHands = vertcat(openHands1, openHands2);
% 平，包含只平和先平后开中平的部分
evenHands1 = [totalTargetList.date(2:end), evenLabel .* table2array(totalTargetList(2:end, 2:end))];
evenHands2 =[totalTargetList.date(2:end), - multiLabel .* ...
    table2array(remainList(:, 2:end))];
evenHands = vertcat(evenHands1, evenHands2);

% 汇总
openHands = array2table(openHands, 'VariableNames', varNames);
evenHands = array2table(evenHands, 'VariableNames', varNames);
totalTargetListBck.Variety = cellfun(@char, totalTargetListBck.Variety, 'UniformOutput', false);

openHands = varfun(@sum, openHands, 'GroupingVariables', 'date');
openHands = openHands(:, [1, 3:end]);
openHands.Properties.VariableNames = varNames;
% 加上第一行，全开
openHands = vertcat(totalTargetList(1, :), openHands);
openHands = stack(openHands, 2:width(openHands), 'NewDataVariableName', 'Hands', 'IndexVariableName', 'Variety');
openHands.Variety = cellstr(openHands.Variety);
openHands = outerjoin(openHands, unique(totalTargetListBck(:, {'date', 'Variety', 'futCont'})), ...
    'type', 'left', 'MergeKeys', true, 'Keys', {'date', 'Variety'});
openHands = openHands(openHands.Hands ~= 0, :);
assert(all(cellfun(@isempty, openHands.futCont) == 0), 'There are variety with valid hands and no main contract!')
openHands.Mark = repmat({'开'}, height(openHands), 1);

evenHands = varfun(@sum, evenHands, 'GroupingVariables', 'date');
evenHands = evenHands(:, [1, 3:end]);
evenHands.Properties.VariableNames = varNames;
evenHands = stack(evenHands, 2:width(evenHands), 'NewDataVariableName', 'Hands', 'IndexVariableName', 'Variety');
evenHands.Variety = cellstr(evenHands.Variety);
evenHands = outerjoin(evenHands, unique(totalTargetListBck(:, {'date', 'Variety', 'futCont'})), ...
    'type', 'left', 'MergeKeys', true, 'Keys', {'date', 'Variety'});
evenHands = evenHands(evenHands.Hands ~= 0, :);
assert(all(cellfun(@isempty, evenHands.futCont) == 0), 'There are variety with valid hands and no main contract!')
evenHands.Mark = repmat({'平'}, height(evenHands), 1);

totalConvertHands = vertcat(openHands, evenHands);
totalConvertHands.time = repmat(999999999, height(totalConvertHands), 1);
totalConvertHands.TargetP = nan(height(totalConvertHands), 1);
totalConvertHands.TargetC = nan(height(totalConvertHands), 1);
totalConvertHands.Variety = [];
totalConvertHands = sortrows(totalConvertHands, {'date', 'Mark', 'futCont'});
totalConvertHands = totalConvertHands(:, {'date', 'time', 'futCont', 'Hands', 'TargetP', 'TargetC', 'Mark'});



%% 输入回测平台
[backtestResultNet, backtestAnalysisNet] = ...
    CTABacktest_GeneralPlatform_v2_1(totalConvertHands, strategyPara, tradingPara);
% 走势和各个策略的净值平均一样，绝对值会好一些





