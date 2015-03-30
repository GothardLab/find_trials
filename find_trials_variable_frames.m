 %function [trial] = find_trials_showmoviephysio(spikeFilePath, itemFilePath)
spikeFilePath = 'D:\dat\smr\ImageMovieTest.smr';

%[itemFileDir,itemFileName,itemFileExt] = fileparts(itemFilePath);
[spikeFileDir,spikeFileName,spikeFileExt] = fileparts(spikeFilePath);

%itemFile = loadItemFile(itemFilePath);
spikeFile = load_smr(spikeFilePath);

%numberItems = size(itemFile,1);

for chanDex = 1:size(spikeFile,2)
    if strcmp(spikeFile(chanDex).title, 'conditio') || strcmp(spikeFile(chanDex).title, 'DigMark') 
        condChan = chanDex;
    end
end

conditionChan = spikeFile(condChan);

times = conditionChan.data.timings;
events = conditionChan.data.markers;

events(:,2:4) = [];

if events(1)==0;
    events(1)=[];
    times(1)=[];
end

badones=find(diff(times)<0.002)+1;
times(badones)=[];
events(badones)=[];

c=0;
diffmarks=[diff(times)];
for i=1:length(events)-1;
    if (diffmarks(i)>0.002 && diffmarks(i)<0.006);
        c=c+1;
        lob(c)=events(i);
        hib(c)=events(i+1);
        marktimes(c)=times(i);
    end
end

for i=1:length(lob);
    hiblob(i)=double(lob(i))+(double(hib(i))*256);
end
marktimes(hiblob==0)=[];
hiblob(hiblob==0)=[];


% cueon=find(hiblob==35); %find all marker 35s which indicate the cue before the movie has turned on
% for i=1:length(cueon);  %scroll through all the cue on times
%     movietrial(i).cueon=marktimes(cueon(i));    %for each movie trial, record the cueon time in a structure
%     if hiblob(cueon(i)+1)==36;  %if the next marker is 36 (cue off) then...
%         movietrial(i).cueoff=marktimes(cueon(i)+1);%...record the cue off time in the structure
%     end
%     if hiblob(cueon(i)+2)>256*255;  %if the next value after cue off is greater than FF*256 then this is the movie number
%         movietrial(i).moviecnd=hiblob(cueon(i)+2)-256*255;  %calculate the movie cnd number and record it in the structure
%         movietrial(i).movieon=marktimes(cueon(i)+2);    %record the time that the move cam on in the structure
%     end
%     if i<length(cueon); %if this is not the last movie to be presented for the day then...
%         movietrial(i).framenum=hiblob(cueon(i)+3:cueon(i+1)-1)-1000;    %then take all the markers before the next cue appears and calculate teh frame numbers
%         movietrial(i).frametime=marktimes(cueon(i)+3:cueon(i+1)-1); %record the times that each frame came on
%     end
%     if i==length(cueon);    %if this is the last movie of the day to be presented
%         movietrial(i).framenum=hiblob(cueon(i)+3:length(hiblob))-1000;  %then all the remaining markers are frame numbers; record them
%         movietrial(i).frametime=marktimes(cueon(i)+3:length(hiblob));   %record the time that each frame was presented.
%     end
% end
%


% movieFrames = [1001:1299];
% allCodes = hiblob;
% allTimes = marktimes;
% 
% movieCandidates = cell(1, numel(movieFrames));
% for p = 1:(numel(movieFrames))
%     movieCandidates{p} = find(allCodes == movieFrames(p));
% end
% 
% movieCandidateStartIndexs = movieCandidates{1};
% movieCandidateStartTimes = allTimes(movieCandidates{1});
% 
% for i = 1:size(movieCandidateStartIndexs,2)
%     
%     fprintf('\t\tTrial:%3d\t', i);
%     movie(i).error = 1;
%      movie(i).condition = allCodes(movieCandidateStartIndexs(i)-1)-256*255;
%                fprintf('Condition: %2d\t', movie(i).condition);
%     
%     if size(allCodes,2) >= movieCandidateStartIndexs(i)+298 && ismember(movie(i).condition, [1:size(itemFile,1)])
%         expectedFrameIndexs = [movieCandidateStartIndexs(i):movieCandidateStartIndexs(i)+298];
%         expectedFrameCodes = allCodes(expectedFrameIndexs);
%         expectedFrameTimes = allTimes(expectedFrameIndexs);
% 
%         frameErrors = 0;
% 
%         correctTimes = nan(1,size(movieFrames,2));
%         correctFrames = nan(1,size(movieFrames,2));
% 
%         for j = 1:size(movieFrames,2)
%             expectedFrame = movieFrames(j);
% 
%             if size(find(expectedFrameCodes == expectedFrame),2) == 0 %If there is a missing frame
%                 frameErrors=frameErrors+1;
%                 fprintf('%d? ', expectedFrame);
% 
%                 if expectedFrame == movieFrames(end)
%                     correctFrames(j) = movieFrames(end);
%                     correctTimes(j) = expectedFrameTimes(end);  
%                 end
% 
%             elseif size(find(expectedFrameCodes == expectedFrame),2) > 1
%                 frameErrors=frameErrors+1;
%                 fprintf('%dx%d ', expectedFrame, size(find(expectedFrameCodes == expectedFrame),2));
%             else
%                 index = find(expectedFrameCodes == expectedFrame);
% 
%                 correctFrames(j) = expectedFrameCodes(index);
%                 correctTimes(j) = expectedFrameTimes(index);
%             end
% 
% 
%         end
% 
%         interpFrames=correctFrames-1000;
%         interpTimes=correctTimes;
%         interpFrames(size(movieFrames,2)+1) = nan;
%         interpTimes(size(movieFrames,2)+1) = nan;
%         interpFrames(isnan(interpFrames)) = interp1(find(~isnan(interpFrames)), interpFrames(~isnan(interpFrames)), find(isnan(interpFrames)), 'PCHIP');
%         interpTimes(isnan(interpTimes)) = interp1(find(~isnan(interpTimes)), interpTimes(~isnan(interpTimes)), find(isnan(interpTimes)), 'PCHIP');
% 
%         if interpFrames == [1:300]
% 
% 
% 
%             for j = 1:size(movieFrames,2)
% 
%                 if j == interpFrames(j)
%                     movie(i).frame(j).start = interpTimes(j);
%                     movie(i).frame(j).end  = interpTimes(j+1);
%                 else
%                     movie(i).error = 1;
%                     error('Movie %d error', i);
%                 end
%             end
% 
%            
% 
%             movie(i).start = interpTimes(1);
%             movie(i).end = interpTimes(end);
%             movie(i).stimFile = itemFile{movie(i).condition};
%             movie(i).itemFile = itemFileName;
%             movie(i).dataFile = spikeFileName;
%             movie(i).frameErrors=frameErrors;
%             movie(i).error = 0;
%              fprintf('Errors:%d\t', movie(i).frameErrors);
%         else
%             movie(i).error = 1;
%             error('Movie %d error', i);
%         end
%     else
%         movie(i).error = 1;
%           fprintf('Movie stopped early or invalid condition');
%     end
%     fprintf('\n');
% end
% 
% movieViewCounts = zeros(1,size(movie,2));
% validMovieCount = 0;
% for movieIndex = 1:size(movie,2)
%     
%     if ~movie(movieIndex).error 
%         
%      validMovieCount = validMovieCount+1;
%      
%      movieViewCounts(movie(movieIndex).condition) = movieViewCounts(movie(movieIndex).condition)+1;
%      movie(movieIndex).viewing = movieViewCounts(movie(movieIndex).condition);
%        trial(validMovieCount).frame = movie(movieIndex).frame;
%       trial(validMovieCount).viewing = movie(movieIndex).viewing;
%        trial(validMovieCount).start = movie(movieIndex).start;
%        trial(validMovieCount).end = movie(movieIndex).end;
%        trial(validMovieCount).stimFile = movie(movieIndex).stimFile;
%        trial(validMovieCount).itemFile = movie(movieIndex).itemFile;
%        trial(validMovieCount).dataFile = movie(movieIndex).dataFile;
%        trial(validMovieCount).frameErrors = movie(movieIndex).frameErrors;
%          trial(validMovieCount).condition = movie(movieIndex).condition;
%      
%     end
% end


