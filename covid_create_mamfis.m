function fis = covid_create_mamfis()
    fis = mamfis('Name','COVID_Door_System');

    % Input 1: Body Temperature
    fis = addInput(fis,[97 101],'Name','BodyTemp');
    fis = addMF(fis,'BodyTemp','trimf',[97 97 98],'Name','BelowNormal');
    fis = addMF(fis,'BodyTemp','trimf',[97 98 99],'Name','Normal');
    fis = addMF(fis,'BodyTemp','trimf',[98 99 100],'Name','Temp');
    fis = addMF(fis,'BodyTemp','trimf',[99 100 101],'Name','HighTemp');
    fis = addMF(fis,'BodyTemp','trimf',[100 101 101],'Name','VeryHigh');

    % Input 2: Mask Compliance
    fis = addInput(fis,[0 8],'Name','MaskCompliance');
    fis = addMF(fis,'MaskCompliance','trimf',[0 0 2],'Name','Count1');
    fis = addMF(fis,'MaskCompliance','trimf',[0 2 4],'Name','Count2');
    fis = addMF(fis,'MaskCompliance','trimf',[2 4 6],'Name','Count3');
    fis = addMF(fis,'MaskCompliance','trimf',[4 6 8],'Name','Count4');
    fis = addMF(fis,'MaskCompliance','trimf',[6 8 8],'Name','Count5');

   
    % Output: Door
    fis = addOutput(fis,[0 1],'Name','Door');
    fis = addMF(fis,'Door','trimf',[-0.1 0 0.1],'Name','Close');
    fis = addMF(fis,'Door','trimf',[0.9 1 1.1],'Name','Open');

    % Rules
    ruleList = [
        1 1 2 1 2; 2 1 2 1 2; 3 1 1 1 1; 4 1 1 1 1; 5 1 1 1 1;
        1 2 2 1 2; 2 2 2 1 2; 3 2 1 1 1; 4 2 1 1 1; 5 2 1 1 1;
        1 3 1 1 1; 2 3 1 1 1; 3 3 1 1 2; 4 3 1 1 1; 5 3 1 1 1;
        1 4 1 1 1; 2 4 1 1 1; 3 4 1 1 2; 4 4 1 1 2; 5 4 1 1 1;
        1 5 1 1 1; 2 5 1 1 1; 3 5 1 1 2; 4 5 1 1 2; 5 5 1 1 1;
    ];
    fis = addRule(fis, ruleList);

