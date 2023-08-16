clc
clear
indics1_pre=[2,3];
indics1_tem=[1,4,5,6,7,8,9,10,11];
indics2_pre=[1,3,7,8,9,10,11,12];
indics2_tem=[2,4,5,6,13,14,15];
color_adr = 'D:\matlab实验数据\colorbar\';
color_map = 'temp_19lev.txt';
out = 'D:\matlab实验数据\testplot\';
color = importdata([color_adr,color_map]);
% 读取地图数据
shape_adr = 'D:\matlab实验数据\极端气候指数工作文件\底图\areat.dbf';
shape = shaperead(shape_adr);
X = [];
Y = [];
for i = 1:length(shape)
X = [X,shape(i).X];
Y = [Y,shape(i).Y];
end
str1 = {'1-4月','5-9月','10-12月','年平均'};
indicesname={'DTR','Rx1day','Rx5day','TN10p','TN90p','TNn','TNx','TX10p',...
    'TX90p','TXn','TXx'};
indicesname1={'CDD','CSDI','CWD','FD','GSL','ID','PRCPTOT','R10mm',...
    'R20mm','R95p','R99p','SDII','SU','TR','WSDI'};
% 读取火灾数据
fire_adr = 'D:\matlab实验数据\data\';
fire_file = 'WFAC-final1.xlsx';
date = {1:4,5:9,10:12,1:12};
data = xlsread([fire_adr,fire_file]);
fire_raw = data(3:end,3:end);
lon = data(1,3:end);
lat = data(2,3:end);
dim = size(fire_raw);
fire_raw_r = reshape(fire_raw,12,14,[]);
% 读取月极端指数
index_yr = 1901:2018;
id = find(index_yr>=2005&index_yr<=2018);
mon = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
index_adr = 'D:\matlab实验数据\极端气候指数工作文件\HADex3 61-90 11个月数据\';
index_file = dir([index_adr,'*.nc']);
% 读取年极端指数
indexa_adr = 'D:\matlab实验数据\极端气候指数工作文件\HADex3 61-90 15个年数据\';
index_filea = dir([indexa_adr,'*.nc']);
% 相关系数文件
pre_tem_adr = 'D:\matlab实验数据\极端气候指数工作文件\平均气温、平均降水与野火的相关系数\新排序后文件\';
pre_file = dir([pre_tem_adr,'*pre.csv']);
tem_file = dir([pre_tem_adr,'*tem.csv']);
for i = 1:length(str1)
    fire_pick = squeeze(sum(fire_raw_r(date{i},:,:),1));
    fire_diff = diff(fire_pick);
    pre_data = xlsread([pre_tem_adr,pre_file(i).name]);
    tem_data = xlsread([pre_tem_adr,tem_file(i).name]);
    pre = pre_data(:,3);
    tem = tem_data(:,3);
    lon_p = pre_data(:,1);
    lat_p = pre_data(:,2);
    lon_t = tem_data(:,1);
    lat_t = tem_data(:,2);
    prel = griddata(lon_p,lat_p,pre,lon,lat,'nearest');
    teml = griddata(lon_t,lat_t,tem,lon,lat,'nearest');
    xlswrite(['D:\matlab实验数据\testplot\',str1{i},'prel','.xls'],prel)
    xlswrite(['D:\matlab实验数据\testplot\',str1{i},'teml','.xls'],teml)
    % 计算月极端指数与野火相关
    if i~=length(str1)
    for j = 1:length(indicesname)
    index = 0;
        for k = 1:length(date{i})
            aa = ncread([index_adr,index_file(j).name],mon{date{i}(k)});
            index = index + aa;
            lat_g = ncread([index_adr,index_file(j).name],'latitude');
            lon_g = ncread([index_adr,index_file(j).name],'longitude');
        end
        ix = find(lon_g>=70&lon_g<=135);
        iy = find(lat_g>=15&lat_g<=55);
        index = index(ix,iy,id)/length(date{i});
        [xx,yy] = meshgrid(lon_g(ix),lat_g(iy));
        for k = 1:length(id)
           index_grid(k,:) = griddata(xx',yy',index(:,:,k),lon,lat,'nearest'); 
        end
        index_diff = diff(index_grid);
        for k = 1:length(lat)
            rr = corrcoef(fire_diff(:,k),index_diff(:,k));
            r(k) = rr(2);
        end          
        figure(1)
        plot(X,Y,'k')
        hold on
        scatter(lon,lat,80,r,'fill','s')
        colormap(color)
        set(gca,'ylim',[10,60],'xlim',[73,137])
        colorbar
        caxis([-1,1])
        title([str1{i},' ',indicesname{j},])
        %xlswrite(['D:\matlab实验数据\testplot\',str1{i},'_',indicesname{j},'.xls'],r)
        saveas(figure(1),['D:\matlab实验数据\testplot\',str1{i},'_',indicesname{j},'_','.png'])
        clf
         % 计算月极端指数-野火相关与气温/降水差值
        if ismember(j,indics1_pre)
           r_diff = abs(r)-abs(prel);
           strr = 'pre';
        else 
           r_diff = abs(r)-abs(teml);
           strr = 'tem';
        end
        figure(1)
        plot(X,Y,'k')
        hold on
        scatter(lon,lat,80,r_diff,'fill','s')
        colormap(color)
        set(gca,'ylim',[10,60],'xlim',[73,137])
        colorbar
        caxis([-0.5,0.5])
        title([str1{i},' ',indicesname{j},'-',strr])
        saveas(figure(1),['D:\matlab实验数据\testplot\',str1{i},'_',indicesname{j},'-',strr,'.png'])
        clf
        %xlswrite(['D:\matlab实验数据\testplot\',str1{i},'_',indicesname{j},'-',strr,'.xls'],r_diff)
    end
    % 计算年极端指数于野火相关
    else
        for j = 1:length(indicesname1)
            indexa = ncread([indexa_adr,index_filea(j).name],'Ann');
            indexa = indexa(:,:,id);
            for k = 1:length(id)
               indexa_grid(k,:) = griddata(xx',yy',indexa(ix,iy,k),lon,lat,'nearest'); 
            end
            indexa_diff = diff(indexa_grid);
            for k = 1:length(lat)
                rr = corrcoef(fire_diff(:,k),indexa_diff(:,k));
                ra(k) = rr(2);
            end
            figure(1)
            plot(X,Y,'k')
            hold on
            scatter(lon,lat,80,ra,'fill','s')
            colormap(color)
            set(gca,'ylim',[10,60],'xlim',[73,137])
            colorbar
            caxis([-1,1])
            title([str1{i},' ',indicesname1{j},])
            %xlswrite(['D:\matlab实验数据\testplot\',str1{i},'_',indicesname1{j},'.xls'],ra)
            saveas(figure(1),['D:\matlab实验数据\testplot\','年平均',indicesname1{j},'_','.png'])
            clf
        % 计算年极端指数-野火相关与气温/降水差值
        if ismember(j,indics2_pre)
           disp(j)
           r_diff = abs(ra)-abs(prel);
           strr = 'pre';
        else 
           r_diff = abs(ra)-abs(teml);
           strr = 'tem';
        end
        figure(1)
        plot(X,Y,'k')
        hold on
        scatter(lon,lat,80,r_diff,'fill','s')
        colormap(color)
        set(gca,'ylim',[10,60],'xlim',[73,137])
        colorbar
        caxis([-0.5,0.5])
        title([str1{i},' ',indicesname1{j},'-',strr])
        saveas(figure(1),['D:\matlab实验数据\testplot\',str1{i},'_',indicesname1{j},'-',strr,'.png'])
        %xlswrite(['D:\matlab实验数据\testplot\',str1{i},'_',indicesname1{j},'-',strr,'.xls'],r_diff)
        clf
        end
    end
end

