clear all
addpath('15.plug pmf_office','16.plug pmf_household','Dist_error')

n = 10000; % ev 개수
x = 20; % error rate
office = 1; % 1 : office, 0 : house
error = 1; % 1 : error input 0 : no

if office == 1
    data_out_office = input_office(n,error,x);
else
    data_out_house = input_household(n,error,x);
end

if error == 1
    if office == 1
        error_data = readmatrix('15.plug pmf_office/out_plug_time_error.csv');
        data_office = readmatrix('15.plug pmf_office/out_plug_time.csv');
        gap = error_data - data_office;
    else
        error_data = readmatrix('16.plug pmf_household/out_plug_time_error.csv');
        data_household = readmatrix('16.plug pmf_household/out_plug_time.csv');
        gap = error_data - data_household;
    end
%     for i = 1 : size(gap,2)
%         figure(i)
%         histfit(gap(:,i));
%         text = sprintf("graph/error_data%d.jpg",i);
%         text_title = ["in time","out time","init SoC"];
%         title(text_title(i),'fontsize',14)
%         exportgraphics(figure(i),text,'Resolution',300);
%         close
%     end
end