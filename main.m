cd E:\Repository\isolateBacktest
addpath BacktestPlatform_for_futs_v2

% E:\outSample\singleFactorStrategy\testResult����洢������backtestSummary.m�Ѹ������Ծ�ֵƽ���õ���
% �����ȡ�������ԵĽ��׵���ÿ�����Էֱ�ز�һ�����ں˶�
% �������н��׵���������õ��ܾ�ֵ�������������ܾ�ֵ���ֱ��ƽ����ֵЧ����һ��

%% ��ȡ���н��׵�

% �ֻ�������ӽ��׵�
fileFolder = fullfile('Z:\FRL\factorStrategy\spotPremium');
dirOutput = dir(fullfile(fileFolder, '*'));
allFileNames = {dirOutput.name}';

updDate = regexp(allFileNames, '(?<=-)\d+', 'match');
updDate = cellfun(@(x) cell2mat(x), updDate, 'UniformOutput', false);
updDate = max(str2double(updDate));
%% �ز����
strategyPara.crossType = 'dn';
strategyPara.freqK = 'Dly';
strategyPara.stDate = 20190311;
strategyPara.edDate = updDate;

tradingPara.futDataPath = '\\CJ-LMXUE-DT\futureData_fromWind\priceData_byFut'; %�ڻ�������Լ����·��
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

% �ֵ����ӽ��׵�
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

%% �ϳɽ��׵�
totalTargetList = vertcat(targetListTotalSP60, targetListTotalSP90, ...
    targetListTotalWT90, targetListTotalWT250);
% ����
totalTargetList = varfun(@sum, totalTargetList, 'GroupingVariables', {'date', 'time', 'futCont' 'Mark'});
totalTargetList = totalTargetList(:, {'date', 'time', 'futCont', 'sum_hands', 'sum_targetP', 'sum_targetC', 'Mark'});
totalTargetList.Properties.VariableNames = {'date', 'time', 'futCont', 'Hands', 'TargetP', 'TargetC', 'Mark'};
% �����Ľ����Ҫ��Mark���´���  �����getTargetList�д�����̫һ������Ϊ����Ҫshift�����Ŀ��ֲ�ת��Ϊ��������
% ������Ѿ���ÿ����Ҫ�����Ľ��׵���Ҳ����ǰһ��-4�� ��һ��16�� ����Ҫ��������ڶ�����Ҫ��������ƽ4�֣��ٿ�12�֡�
% ������Ҫ�Ե�ǰ�����Ľ��׵�����һ����ƽ�������


totalTargetList.Variety = regexp(totalTargetList.futCont, '^[A-Z]+', 'match');
totalTargetListBck = totalTargetList;
totalTargetList.Variety = cellfun(@char, totalTargetList.Variety, 'UniformOutput', false);
totalTargetList = unstack(totalTargetList(:, {'date', 'Variety', 'Hands'}), 'Hands', 'Variety');
% �ѿ���ƽ����������ӱ�ǩ���ٺϵ�һ��
varNames = totalTargetList.Properties.VariableNames;
totalTargetList = array2table([totalTargetList.date, ...
    arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), table2array(totalTargetList(:, 2:end)))], ...
    'VariableNames', varNames);

shiftTotalTList = totalTargetList(1:end-1, :);
% ��һ��ȫ������'��'�� �ӵڶ��п�ʼ�Ա�

% @2019.03.26 ֮ǰ�и�ϸ�ڴ��ˣ����Ǹ���һ�еķ���ȥ�Աȣ�����Ӧ�ø���һ��δƽ����������ȥ�Աȣ���Ҫ��ͣ�
remainList = array2table([shiftTotalTList.date, cumsum(table2array(shiftTotalTList(:, 2:end)), 1)], ...
    'VariableNames', totalTargetList.Properties.VariableNames);
% ֻ��������
openLabel = sign(table2array(totalTargetList(2:end, 2:end))) == sign(table2array(remainList(:, 2:end))) | ...
    (table2array(remainList(:, 2:end)) == 0 & table2array(totalTargetList(2:end, 2:end)) ~= 0);
% ֻ��ƽ����
evenLabel = sign(table2array(totalTargetList(2:end, 2:end))) ~= sign(table2array(remainList(:, 2:end))) & ...
    abs(table2array(totalTargetList(2:end, 2:end))) <= abs(table2array(remainList(:, 2:end)));
% ��ƽ�󿪣�
multiLabel = sign(table2array(totalTargetList(2:end, 2:end))) ~= sign(table2array(remainList(:, 2:end))) & ...
    abs(table2array(totalTargetList(2:end, 2:end))) > abs(table2array(remainList(:, 2:end))) & ...
    sign(table2array(remainList(:, 2:end))) ~= 0;
% ��������ֻ������ƽ���п��Ĳ���
openHands1 = [totalTargetList.date(2:end), openLabel .* table2array(totalTargetList(2:end, 2:end))];
openHands2 = [totalTargetList.date(2:end), multiLabel .* ...
    (table2array(totalTargetList(2:end, 2:end)) + table2array(remainList(:, 2:end)))];
openHands = vertcat(openHands1, openHands2);
% ƽ������ֻƽ����ƽ����ƽ�Ĳ���
evenHands1 = [totalTargetList.date(2:end), evenLabel .* table2array(totalTargetList(2:end, 2:end))];
evenHands2 =[totalTargetList.date(2:end), - multiLabel .* ...
    table2array(remainList(:, 2:end))];
evenHands = vertcat(evenHands1, evenHands2);

% ����
openHands = array2table(openHands, 'VariableNames', varNames);
evenHands = array2table(evenHands, 'VariableNames', varNames);
totalTargetListBck.Variety = cellfun(@char, totalTargetListBck.Variety, 'UniformOutput', false);

openHands = varfun(@sum, openHands, 'GroupingVariables', 'date');
openHands = openHands(:, [1, 3:end]);
openHands.Properties.VariableNames = varNames;
% ���ϵ�һ�У�ȫ��
openHands = vertcat(totalTargetList(1, :), openHands);
openHands = stack(openHands, 2:width(openHands), 'NewDataVariableName', 'Hands', 'IndexVariableName', 'Variety');
openHands.Variety = cellstr(openHands.Variety);
openHands = outerjoin(openHands, unique(totalTargetListBck(:, {'date', 'Variety', 'futCont'})), ...
    'type', 'left', 'MergeKeys', true, 'Keys', {'date', 'Variety'});
openHands = openHands(openHands.Hands ~= 0, :);
assert(all(cellfun(@isempty, openHands.futCont) == 0), 'There are variety with valid hands and no main contract!')
openHands.Mark = repmat({'��'}, height(openHands), 1);

evenHands = varfun(@sum, evenHands, 'GroupingVariables', 'date');
evenHands = evenHands(:, [1, 3:end]);
evenHands.Properties.VariableNames = varNames;
evenHands = stack(evenHands, 2:width(evenHands), 'NewDataVariableName', 'Hands', 'IndexVariableName', 'Variety');
evenHands.Variety = cellstr(evenHands.Variety);
evenHands = outerjoin(evenHands, unique(totalTargetListBck(:, {'date', 'Variety', 'futCont'})), ...
    'type', 'left', 'MergeKeys', true, 'Keys', {'date', 'Variety'});
evenHands = evenHands(evenHands.Hands ~= 0, :);
assert(all(cellfun(@isempty, evenHands.futCont) == 0), 'There are variety with valid hands and no main contract!')
evenHands.Mark = repmat({'ƽ'}, height(evenHands), 1);

totalConvertHands = vertcat(openHands, evenHands);
totalConvertHands.time = repmat(999999999, height(totalConvertHands), 1);
totalConvertHands.TargetP = nan(height(totalConvertHands), 1);
totalConvertHands.TargetC = nan(height(totalConvertHands), 1);
totalConvertHands.Variety = [];
totalConvertHands = sortrows(totalConvertHands, {'date', 'Mark', 'futCont'});
totalConvertHands = totalConvertHands(:, {'date', 'time', 'futCont', 'Hands', 'TargetP', 'TargetC', 'Mark'});



%% ����ز�ƽ̨
[backtestResultNet, backtestAnalysisNet] = ...
    CTABacktest_GeneralPlatform_v2_1(totalConvertHands, strategyPara, tradingPara);
% ���ƺ͸������Եľ�ֵƽ��һ��������ֵ���һЩ





