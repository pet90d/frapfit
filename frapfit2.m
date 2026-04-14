function frapfit2
numOfFilesInPackage=2;
thisVersionNumbers=zeros(numOfFilesInPackage,1);
% THINGS TO CHANGE WHEN UPGRADING
thisVersionNumbers(1)=58; % frapfit
thisVersionNumbers(2)=19; % frapfit_help.html
% END OF THINGS TO CHANGE WHEN UPGRADING
% check if dipimage is installed
whichDipimage=which('dipimage');
if isempty(whichDipimage)
    errordlg('DipImage is required, install it before using frapfit.','Oops');
    return;
end
versionText=[num2str(1+floor(thisVersionNumbers(1)/100)),'.',num2str(mod(thisVersionNumbers(1),100),'%02.0f')];
scrsz=get(0,'ScreenSize');
dlgsz=[500 600];
btnsz=[140 40];
smallBtnsz=[100 30];
panelsz=[dlgsz(1)-170 dlgsz(2)-50];
yellowColorDef=[240/255 240/255 60/255];
blueColorDef=[121/255 158/255 231/255];
greenColorDef=[100/255 200/255 115/255];
dh=dialog('Name','Analysis of FRAP experiment (FRAPfit)','Position',[(scrsz(3)-dlgsz(1))/2 (scrsz(4)-dlgsz(2))/2 dlgsz],'windowstyle','normal','toolbar','none','menubar','none','units','pixels');
bh(1)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string',['<HTML><center><FONT color="red"><b>Load images</Font></b>'],'enable','off','userdata','Load images');
ph(1)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Load images','fontsize',10);
bh(2)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Read bleachng ROI','enable','off','userdata','Read bleachng ROI');
ph(2)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Read bleaching ROI','fontsize',10);
bh(3)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Register images','enable','off','userdata','Register images');
ph(3)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Register images','fontsize',10);
bh(4)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Smooth and export','enable','off','userdata','Smooth and export');
ph(4)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Smooth and export image','fontsize',10);
bh(5)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Set bleaching ROI','enable','off','userdata','Set bleaching ROI');
ph(5)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Set bleaching ROI','fontsize',10);
bh(6)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Set unbleached ROI','enable','off','userdata','Set unbleached ROI');
ph(6)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Set unbleached ROI','fontsize',10);
bh(7)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Set background ROI','enable','off','userdata','Set background ROI');
ph(7)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Set background ROI','fontsize',10);
bh(8)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Draw ROIs on image','enable','off','userdata','Draw ROIs on image');
ph(8)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Draw ROIs on image','fontsize',10);
bh(9)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Get curve and fit','enable','off','userdata','Get curve and fit');
ph(9)=uipanel('parent',dh,'units','pixels','position',[160 40 panelsz],'title','Generate curve and fit','fontsize',10);
bh(10)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Update','enable','off','backgroundcolor',greenColorDef);
bh(11)=uicontrol('parent',dh,'style','pushbutton','units','pixels','fontsize',10,'string','Help','enable','off','backgroundcolor',yellowColorDef,'callback',@help_callback);
setButtonPositions(bh,btnsz,10,dlgsz(2)-50,10);
gd.mainbuttonhandles=bh;
gd.mainpanelhandles=ph;
gd.displayWindowHandle=0;
gd.viewedImage=[];
gd.drawState=0; % 0 - draw never pressed, 1 - draw pressed, 2 - finish pressed
gd.bleachRoiStruct=[]; % struct with 2 fields: roiType, roiData
gd.membraneRoiStruct=[];
gd.bgRoiStruct=[];
gd.bleachRoi=[];
gd.bgRoi=[];
gd.membraneRoi=[];
gd.bleachRoiImageType=0; % 1 - 2D, 2 - 3D
gd.bgRoiImageType=0;
gd.membraneRoiImageType=0;
gd.currentRoiCoord1=[];
gd.currentRoiCoord2=[];
gd.currentRoiType=[]; % 'Rectangle', 'Circle'
gd.finishedRoi=0;
gd.roiVertexObjectH=[];
gd.roiEdgeObjectH=[];
gd.roiObjectH=[];
gd.roiVertexSize=6;
gd.firstClickXY=[];
gd.selectiontype=0;
gd.whichselected=0;
gd.currentAction='';
gd.overlayfigureH=0;
gd.overlayaxisH=0;
gd.allRoisOnOverlayH=[0,0,0];
gd.initializationParams=zeros(3,3); % initial value, lower bound and upper bound of fitted parameters
gd.fitType=1; % 1 - 1-exp, 2 - 2-exp
gd.constantParameter=false(5,1); % true if the parameter is constant
gd.frapCurve=[];
gd.bl=[];
gd.bg=[];
gd.tot=[];
gd.recoveryInterval=[];
gd.prebleachInterval=[];
gd.whichLineClicked=0;
gd.lh=[]; % handles of lines defining the prebleach and bleach intervals
gd.frapCurvePlotH=[];
gd.manuallySelectedPoints=[];
gd.withinRangeFrapPoints=[];
gd.withinRangePreBleachPoints=[];
gd.frapFitCurvePlotH=[];
gd.residualPlotH=[];
gd.fittedCurve=[];
gd.residualCurve=[];
gd.listenerForOverlay=0;
gd.listenerForSmoothing=0;
gd.facealpha=0.2;
gd.framerate=10;
gd.handleoftimer=0;
gd.currentSlice=1; % slice shown in the Draw ROIs on image panel
gd.activewindow=dh;
gd.fitSuccess=false;
try
    gd.imagefilepath=evalin('base','imagefilepath_frapfit');
    if ~ischar(gd.imagefilepath)
        gd.imagefilepath='';
    end
catch
    gd.imagefilepath='';
end
try
    gd.resultfilepath=evalin('base','resultfilepath_frapfit');
    if ~ischar(gd.resultfilepath)
        gd.resultfilepath='';
    end
catch
    gd.resultfilepath='';
end
peterHandle=uicontrol('parent',dh,'style','text','units','pixels','fontsize',10,'fontweight','bold','foregroundcolor','blue','position',[10 10 220 20],'string','Written by Peter Nagy','horizontalalignment','center','userdata',0,'enable','inactive');
lazyTextHandle=uicontrol('parent',dh,'style','text','units','pixels','fontsize',10,'fontweight','bold','foregroundcolor','red','position',[240 10 200 20],'string','Nothing to do','horizontalalignment','center');
uicontrol('parent',dh,'style','text','units','pixels','fontsize',10,'fontweight','bold','foregroundcolor','black','position',[dlgsz(1)-50 10 40 20],'string',['v',versionText],'horizontalalignment','left');
set(dh,'windowbuttonmotionfcn',{@mouseOverTarget_callback,peterHandle});
% panel 1, load images
subpanelHeight=panelsz(2)/2-20;
subpanelWidth=panelsz(1)-20;
seqSubpanel=uipanel('parent',ph(1),'units','pixels','position',[10 panelsz(2)/2 subpanelWidth subpanelHeight],'fontsize',10,'title','Read image sequence');
    readImagesButtonHandle=uicontrol('parent',seqSubpanel,'style','pushbutton','fontsize',10,'units','pixels','position',[(subpanelWidth-200)/2 subpanelHeight-60 200 30],'string','Select a file from the sequence','enable','off');
    uicontrol('parent',seqSubpanel,'style','text','fontsize',10,'units','pixels','position',[10 subpanelHeight-90 subpanelWidth-20 20],'string','Filename (one in the series)');
    filenameTextHandle=uicontrol('parent',seqSubpanel,'style','text','fontsize',10,'units','pixels','position',[10 subpanelHeight-190 subpanelWidth-20 100],'backgroundcolor',yellowColorDef);
    uicontrol('parent',seqSubpanel,'style','text','fontsize',10,'units','pixels','position',[10 subpanelHeight-220 300 20],'string','Variable name','horizontalalignment','left');
    inputForReadStack=uicontrol('parent',seqSubpanel,'style','edit','fontsize',10,'units','pixels','position',[10 subpanelHeight-240 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
    loadDoitH=uicontrol('parent',seqSubpanel,'style','pushbutton','fontsize',10,'units','pixels','position',[150 subpanelHeight-240 btnsz],'backgroundcolor',blueColorDef,'string','Read sequence','callback',{@readImagesDoIt_callback,inputForReadStack,filenameTextHandle,lazyTextHandle,dh},'enable','off');
    set(readImagesButtonHandle,'callback',{@select_file_callback,filenameTextHandle,dh});
cziSubpanel=uipanel('parent',ph(1),'units','pixels','position',[10 10 subpanelWidth subpanelHeight],'fontsize',10,'title','Read CZI image with/without ROI');
    uicontrol('parent',cziSubpanel,'style','text','units','pixels','position',[10 subpanelHeight-40 100 20],'fontsize',10,'string','Image variable','horizontalalignment','center');
    inputForReadCziImage=uicontrol('parent',cziSubpanel,'style','edit','units','pixels','position',[10 subpanelHeight-60 100 20],'fontsize',10,'backgroundcolor','white','enable','off');
    uicontrol('parent',cziSubpanel,'style','text','units','pixels','position',[subpanelWidth/2+10 subpanelHeight-40 100 20],'fontsize',10,'string','ROI variable','horizontalalignment','center');
    inputForReadCziRoi=uicontrol('parent',cziSubpanel,'style','edit','units','pixels','position',[subpanelWidth/2+10 subpanelHeight-60 100 20],'fontsize',10,'backgroundcolor','white','enable','off');
    readCziDoitH=uicontrol('parent',cziSubpanel,'style','pushbutton','fontsize',10,'units','pixels','position',[(subpanelWidth-btnsz(1))/2 subpanelHeight-150 btnsz],'backgroundcolor',blueColorDef,'string','Read image','callback',{@readCziDoIt_callback,inputForReadCziImage,inputForReadCziRoi,lazyTextHandle,seqSubpanel,dh},'enable','off');
% panel 2, read bleaching ROI
uicontrol('parent',ph(2),'style','text','fontsize',10,'units','pixels','position',[10 500 150 20],'string','Variable name','horizontalalignment','left');
roiVarNameEditHandle=uicontrol('parent',ph(2),'style','edit','fontsize',10,'units','pixels','position',[10 480 100 20],'horizontalalignment','center','backgroundcolor','white');
readRoiButtonHandle=uicontrol('parent',ph(2),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)-100)/2 420 100 30],'string','Select ROI file','backgroundcolor',blueColorDef);
roiTextHandles(1)=uicontrol('parent',ph(2),'style','text','fontsize',10,'units','pixels','position',[50 360 270 20],'backgroundcolor',yellowColorDef);
roiTextHandles(2)=uicontrol('parent',ph(2),'style','text','fontsize',10,'units','pixels','position',[50 330 270 20],'backgroundcolor',yellowColorDef);
uicontrol('parent',ph(2),'style','text','fontsize',10,'units','pixels','position',[10 360 30 20],'string','X','horizontalalignment','left');
uicontrol('parent',ph(2),'style','text','fontsize',10,'units','pixels','position',[10 330 30 20],'string','Y','horizontalalignment','left');
set(readRoiButtonHandle,'callback',{@readRoiData_callback,roiTextHandles,roiVarNameEditHandle,lazyTextHandle,dh});
% panel 3, register images
uicontrol('parent',ph(3),'style','text','fontsize',10,'units','pixels','position',[10 500 150 20],'string','Source image','horizontalalignment','left');
inputRegisterEditHandle=uicontrol('parent',ph(3),'style','edit','fontsize',10,'units','pixels','position',[10 480 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(3),'style','text','fontsize',10,'units','pixels','position',[175 500 120 20],'string','Result image','horizontalalignment','left');
outputRegisterEditHandle=uicontrol('parent',ph(3),'style','edit','fontsize',10,'units','pixels','position',[175 480 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(3),'style','text','fontsize',10,'units','pixels','position',[10 450 150 20],'string','Shift vector','horizontalalignment','left');
outputShiftEditHandle=uicontrol('parent',ph(3),'style','edit','fontsize',10,'units','pixels','position',[10 430 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(3),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)-100)/2 360 100 30],'string','Register','backgroundcolor',blueColorDef,'callback',{@registerImages_callback,inputRegisterEditHandle,outputRegisterEditHandle,outputShiftEditHandle,lazyTextHandle,dh});
% panel 4, smooth and export images
uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[10 500 150 20],'string','Source image','horizontalalignment','left');
inputSmoothEditHandle=uicontrol('parent',ph(4),'style','edit','fontsize',10,'units','pixels','position',[10 480 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[175 500 120 20],'string','Result image','horizontalalignment','left');
outputSmoothEditHandle=uicontrol('parent',ph(4),'style','edit','fontsize',10,'units','pixels','position',[175 480 100 20],'horizontalalignment','center','backgroundcolor','white');
    % slider
    sliderSmoothHandle=uicontrol('parent',ph(4),'style','slider','fontsize',10,'units','pixels','position',[10 410 200 30],'min',1,'max',2,'enable','off','value',1);
    sliderMinTextHandle=uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[10 390 50 20],'string','?','horizontalalignment','left');
    sliderMaxTextHandle=uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[180 390 50 20],'string','?','horizontalalignment','left');
    uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[(panelsz(1)-200)/2 440 150 20],'string','Slice selector','horizontalalignment','left');
    % end of slider
uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[240 430 80 20],'string','Current slice','horizontalalignment','left');
sliceTextHandle=uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[240 410 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
uicontrol('parent',ph(4),'style','text','fontsize',10,'units','pixels','position',[10 360 120 20],'string','SD of Gaussian','horizontalalignment','left');
gaussSmoothEditHandle=uicontrol('parent',ph(4),'style','edit','fontsize',10,'units','pixels','position',[10 340 100 20],'horizontalalignment','center','backgroundcolor','white','callback',{@gauss_callback,dh});
sliceOrWholeHandle=uibuttongroup('parent',ph(4),'fontsize',10,'units','pixels','position',[165 300 155 80],'title','What to export');
    rbSliceWhole(1)=uicontrol('parent',sliceOrWholeHandle,'style','radiobutton','fontsize',10,'units','pixels','position',[10 35 100 20],'string','Single slice');
    rbSliceWhole(2)=uicontrol('parent',sliceOrWholeHandle,'style','radiobutton','fontsize',10,'units','pixels','position',[10 10 100 20],'string','Whole stack');
checkBoxExportH=uicontrol('parent',ph(4),'style','checkbox','units','pixels','fontsize',10,'position',[(panelsz(1)-250)/2 250 250 20],'string','Delete image when finished viewing','value',1);
viewH=uicontrol('parent',ph(4),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)/2-100)/2 200 100 30],'string','Start viewing','backgroundcolor',blueColorDef,'userdata',0);
exportH=uicontrol('parent',ph(4),'style','pushbutton','fontsize',10,'units','pixels','position',[(1.5*panelsz(1)-100)/2 200 100 30],'string','Export','backgroundcolor',blueColorDef,'callback',{@exportImages_callback,inputSmoothEditHandle,outputSmoothEditHandle,sliderSmoothHandle,rbSliceWhole,gaussSmoothEditHandle,lazyTextHandle,dh});
set(viewH,'callback',{@viewImages_callback,inputSmoothEditHandle,sliderSmoothHandle,sliceTextHandle,sliderMinTextHandle,sliderMaxTextHandle,gaussSmoothEditHandle,exportH,checkBoxExportH,dh});
% panel 5, set bleaching ROI
vSizeBleachGroup=200;
bleachRoiSourceGroup=uibuttongroup('parent',ph(5),'fontsize',10,'units','pixels','position',[10 panelsz(2)-vSizeBleachGroup-20 panelsz(1)-20 vSizeBleachGroup],'title','Source of bleaching ROI');
    bleachRoiSource(1)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-50 200 20],'string','Image','userdata',1);
    bleachRoiSource(2)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-75 200 20],'string','Imported ROI','userdata',2);
    bleachRoiSource(3)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-100 200 20],'string','Draw polygon','userdata',3);
    bleachRoiSource(4)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-125 200 20],'string','Draw rectangle','userdata',4);
    bleachRoiSource(5)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-150 200 20],'string','Draw square','userdata',5);
    bleachRoiSource(6)=uicontrol('parent',bleachRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-175 200 20],'string','Draw circle','userdata',6);
uicontrol('parent',ph(5),'style','text','fontsize',10,'units','pixels','position',[10 300 100 20],'string','Source image','horizontalalignment','left');
sourceImageHbleach=uicontrol('parent',ph(5),'style','edit','fontsize',10,'units','pixels','position',[10 280 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(5),'style','text','fontsize',10,'units','pixels','position',[155 300 100 20],'string','Source ROI','horizontalalignment','left');
sourceRoiHbleach=uicontrol('parent',ph(5),'style','edit','fontsize',10,'units','pixels','position',[155 280 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(5),'style','text','fontsize',10,'units','pixels','position',[10 240 150 20],'string','Image to draw on','horizontalalignment','left');
drawonHbleach=uicontrol('parent',ph(5),'style','edit','fontsize',10,'units','pixels','position',[10 220 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off','userdata',1);
uicontrol('parent',ph(5),'style','text','fontsize',10,'units','pixels','position',[10 180 100 20],'string','Result image','horizontalalignment','left');
resultHbleach=uicontrol('parent',ph(5),'style','edit','fontsize',10,'units','pixels','position',[10 160 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(5),'style','text','fontsize',10,'units','pixels','position',[10 120 200 20],'string','Variable for ROI info','horizontalalignment','left');
roiHbleach=uicontrol('parent',ph(5),'style','edit','fontsize',10,'units','pixels','position',[10 100 100 20],'horizontalalignment','center','backgroundcolor','white');
gd.drawBleachH(5)=uicontrol('parent',ph(5),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)/2-smallBtnsz(1))/2 40 smallBtnsz],'string','Draw','backgroundcolor',blueColorDef);
gd.setBleachH(5)=uicontrol('parent',ph(5),'style','pushbutton','fontsize',10,'units','pixels','position',[(1.5*panelsz(1)-smallBtnsz(1))/2 40 smallBtnsz],'string','Set','backgroundcolor',blueColorDef,'callback',{@setRoi_callback,bleachRoiSource,sourceImageHbleach,sourceRoiHbleach,drawonHbleach,resultHbleach,roiHbleach,'bleach',lazyTextHandle,dh});
set(bleachRoiSourceGroup,'selectionchangedfcn',{@roiSource_callback,sourceImageHbleach,sourceRoiHbleach,drawonHbleach,resultHbleach,roiHbleach,bleachRoiSource,gd.drawBleachH(5),gd.setBleachH(5),dh});
set(gd.drawBleachH(5),'callback',{@drawRoi_callback,bleachRoiSource,sourceRoiHbleach,drawonHbleach,resultHbleach,roiHbleach,gd.drawBleachH(5),gd.setBleachH(5),lazyTextHandle,dh});
% panel 6, set unbleached ROI
membraneRoiSourceGroup=uibuttongroup('parent',ph(6),'fontsize',10,'units','pixels','position',[10 panelsz(2)-vSizeBleachGroup-20 panelsz(1)-20 vSizeBleachGroup],'title','Source of unbleached ROI');
    membraneRoiSource(1)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-50 200 20],'string','Image','userdata',1);
    membraneRoiSource(2)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-75 200 20],'string','Imported ROI','userdata',2);
    membraneRoiSource(3)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-100 200 20],'string','Draw polygon','userdata',3);
    membraneRoiSource(4)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-125 200 20],'string','Draw rectangle','userdata',4);
    membraneRoiSource(5)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-150 200 20],'string','Draw square','userdata',5);
    membraneRoiSource(6)=uicontrol('parent',membraneRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-175 200 20],'string','Draw circle','userdata',6);
uicontrol('parent',ph(6),'style','text','fontsize',10,'units','pixels','position',[10 300 100 20],'string','Source image','horizontalalignment','left');
sourceImageHmembrane=uicontrol('parent',ph(6),'style','edit','fontsize',10,'units','pixels','position',[10 280 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(6),'style','text','fontsize',10,'units','pixels','position',[155 300 100 20],'string','Source ROI','horizontalalignment','left');
sourceRoiHmembrane=uicontrol('parent',ph(6),'style','edit','fontsize',10,'units','pixels','position',[155 280 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(6),'style','text','fontsize',10,'units','pixels','position',[10 240 150 20],'string','Image to draw on','horizontalalignment','left');
drawonHmembrane=uicontrol('parent',ph(6),'style','edit','fontsize',10,'units','pixels','position',[10 220 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off','userdata',2);
uicontrol('parent',ph(6),'style','text','fontsize',10,'units','pixels','position',[10 180 100 20],'string','Result image','horizontalalignment','left');
resultHmembrane=uicontrol('parent',ph(6),'style','edit','fontsize',10,'units','pixels','position',[10 160 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(6),'style','text','fontsize',10,'units','pixels','position',[10 120 200 20],'string','Variable for ROI info','horizontalalignment','left');
roiHmembrane=uicontrol('parent',ph(6),'style','edit','fontsize',10,'units','pixels','position',[10 100 100 20],'horizontalalignment','center','backgroundcolor','white');
gd.drawBleachH(6)=uicontrol('parent',ph(6),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)/2-smallBtnsz(1))/2 40 smallBtnsz],'string','Draw','backgroundcolor',blueColorDef);
gd.setBleachH(6)=uicontrol('parent',ph(6),'style','pushbutton','fontsize',10,'units','pixels','position',[(1.5*panelsz(1)-smallBtnsz(1))/2 40 smallBtnsz],'string','Set','backgroundcolor',blueColorDef,'callback',{@setRoi_callback,membraneRoiSource,sourceImageHmembrane,sourceRoiHmembrane,drawonHmembrane,resultHmembrane,roiHmembrane,'membrane',lazyTextHandle,dh});
set(membraneRoiSourceGroup,'selectionchangedfcn',{@roiSource_callback,sourceImageHmembrane,sourceRoiHmembrane,drawonHmembrane,resultHmembrane,roiHmembrane,membraneRoiSource,gd.drawBleachH(6),gd.setBleachH(6),dh});
set(gd.drawBleachH(6),'callback',{@drawRoi_callback,membraneRoiSource,sourceRoiHmembrane,drawonHmembrane,resultHmembrane,roiHmembrane,gd.drawBleachH(6),gd.setBleachH(6),lazyTextHandle,dh});
% panel 7, set bg ROI
bgRoiSourceGroup=uibuttongroup('parent',ph(7),'fontsize',10,'units','pixels','position',[10 panelsz(2)-vSizeBleachGroup-20 panelsz(1)-20 vSizeBleachGroup],'title','Source of background ROI');
    bgRoiSource(1)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-50 200 20],'string','Image','userdata',1);
    bgRoiSource(2)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-75 200 20],'string','Imported ROI','userdata',2);
    bgRoiSource(3)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-100 200 20],'string','Draw polygon','userdata',3);
    bgRoiSource(4)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-125 200 20],'string','Draw rectangle','userdata',4);
    bgRoiSource(5)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-150 200 20],'string','Draw square','userdata',5);
    bgRoiSource(6)=uicontrol('parent',bgRoiSourceGroup,'style','radiobutton','fontsize',10,'units','pixels','position',[10 vSizeBleachGroup-175 200 20],'string','Draw circle','userdata',6);
uicontrol('parent',ph(7),'style','text','fontsize',10,'units','pixels','position',[10 300 100 20],'string','Source image','horizontalalignment','left');
sourceImageHbg=uicontrol('parent',ph(7),'style','edit','fontsize',10,'units','pixels','position',[10 280 100 20],'horizontalalignment','center','backgroundcolor','white');
uicontrol('parent',ph(7),'style','text','fontsize',10,'units','pixels','position',[155 300 100 20],'string','Source ROI','horizontalalignment','left');
sourceRoiHbg=uicontrol('parent',ph(7),'style','edit','fontsize',10,'units','pixels','position',[155 280 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(7),'style','text','fontsize',10,'units','pixels','position',[10 240 150 20],'string','Image to draw on','horizontalalignment','left');
drawonHbg=uicontrol('parent',ph(7),'style','edit','fontsize',10,'units','pixels','position',[10 220 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off','userdata',3);
uicontrol('parent',ph(7),'style','text','fontsize',10,'units','pixels','position',[10 180 100 20],'string','Result image','horizontalalignment','left');
resultHbg=uicontrol('parent',ph(7),'style','edit','fontsize',10,'units','pixels','position',[10 160 100 20],'horizontalalignment','center','backgroundcolor','white','enable','off');
uicontrol('parent',ph(7),'style','text','fontsize',10,'units','pixels','position',[10 120 200 20],'string','Variable for ROI info','horizontalalignment','left');
roiHbg=uicontrol('parent',ph(7),'style','edit','fontsize',10,'units','pixels','position',[10 100 100 20],'horizontalalignment','center','backgroundcolor','white');
gd.drawBleachH(7)=uicontrol('parent',ph(7),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)/2-smallBtnsz(1))/2 40 smallBtnsz],'string','Draw','backgroundcolor',blueColorDef);
gd.setBleachH(7)=uicontrol('parent',ph(7),'style','pushbutton','fontsize',10,'units','pixels','position',[(1.5*panelsz(1)-smallBtnsz(1))/2 40 smallBtnsz],'string','Set','backgroundcolor',blueColorDef,'callback',{@setRoi_callback,bgRoiSource,sourceImageHbg,sourceRoiHbg,drawonHbg,resultHbg,roiHbg,'bg',lazyTextHandle,dh});
set(bgRoiSourceGroup,'selectionchangedfcn',{@roiSource_callback,sourceImageHbg,sourceRoiHbg,drawonHbg,resultHbg,roiHbg,bgRoiSource,gd.drawBleachH(7),gd.setBleachH(7),dh});
set(gd.drawBleachH(7),'callback',{@drawRoi_callback,bgRoiSource,sourceRoiHbg,drawonHbg,resultHbg,roiHbg,gd.drawBleachH(7),gd.setBleachH(7),lazyTextHandle,dh});
% panel 8, overlay ROIs on image
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[10 panelsz(2)-50 150 20],'string','Image to draw on','horizontalalignment','left');
drawonHoverlay=uicontrol('parent',ph(8),'style','edit','fontsize',10,'units','pixels','position',[10 panelsz(2)-70 100 20],'horizontalalignment','center','backgroundcolor','white');
legendAxisH=axes('parent',ph(8),'units','pixels','position',[10 panelsz(2)-190 20 100],'nextplot','add');
gd.legendH(1)=fill([0 1 1 0],[0 0 1 1],'g','edgecolor','g','parent',legendAxisH);
gd.legendH(2)=fill([0 1 1 0],2+[0 0 1 1],'b','edgecolor','b','parent',legendAxisH);
gd.legendH(3)=fill([0 1 1 0],4+[0 0 1 1],'r','edgecolor','r','parent',legendAxisH);
set(gd.legendH,'facealpha',0.1);
set(legendAxisH,'color',get(ph(8),'BackgroundColor'),'visible','off','xlim',[-0.001 1],'ylim',[0 5.001]);
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[40 panelsz(2)-115 70 20],'string','Bleached','horizontalalignment','left');
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[40 panelsz(2)-155 100 20],'string','Unbleached','horizontalalignment','left');
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[40 panelsz(2)-195 100 20],'string','Background','horizontalalignment','left');
showAllRoisBH=uicontrol('parent',ph(8),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)-200)/2 panelsz(2)-380 200 30],'string','Show current ROIs','backgroundcolor',blueColorDef);
movieButtonH=uicontrol('parent',ph(8),'style','pushbutton','fontsize',10,'units','pixels','position',[(panelsz(1)-200)/2 panelsz(2)-520 200 30],'string','Save stack to movie file','backgroundcolor',blueColorDef);
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[10 panelsz(2)-440 200 20],'string','Frame rate (frame/sec)','horizontalalignment','left');
framerateEH=uicontrol('parent',ph(8),'style','edit','fontsize',10,'units','pixels','position',[10 panelsz(2)-460 70 20],'backgroundcolor','white','string',num2str(gd.framerate),'callback',{@setFrameRate_callback,dh});
checkBoxOverlayH=uicontrol('parent',ph(8),'style','checkbox','units','pixels','fontsize',10,'position',[(panelsz(1)-250)/2 panelsz(2)-330 250 20],'string','Delete image when finished viewing','value',1);
    % slider
    slider2Handle=uicontrol('parent',ph(8),'style','slider','fontsize',10,'units','pixels','position',[10 panelsz(2)-270 200 30],'min',1,'max',2,'enable','off','value',1);
    sliderMinTex2tHandle=uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[10 panelsz(2)-290 50 20],'string','?','horizontalalignment','left');
    sliderMaxText2Handle=uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[180 panelsz(2)-290 50 20],'string','?','horizontalalignment','left');
    uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[(panelsz(1)-200)/2 panelsz(2)-240 150 20],'string','Slice selector','horizontalalignment','left');
    % end of slider
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[250 panelsz(2)-250 100 20],'string','Current slice','horizontalalignment','left');
sliceText2Handle=uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[250 panelsz(2)-270 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
emptyOrFilledBgh=uibuttongroup('parent',ph(8),'fontsize',10,'units','pixels','position',[130 panelsz(2)-130 180 100],'title','Format of displayed ROIs');
    emptyOrFilled(1)=uicontrol('parent',emptyOrFilledBgh,'style','radiobutton','fontsize',10,'units','pixels','position',[10 50 100 20],'string','Filled');
    emptyOrFilled(2)=uicontrol('parent',emptyOrFilledBgh,'style','radiobutton','fontsize',10,'units','pixels','position',[10 20 100 20],'string','Empty');
uicontrol('parent',ph(8),'style','text','fontsize',10,'units','pixels','position',[130 panelsz(2)-170 120 20],'string','Transparency (0-1)','horizontalalignment','left');
setTransparencyEH=uicontrol('parent',ph(8),'style','edit','fontsize',10,'units','pixels','position',[130 panelsz(2)-190 70 20],'backgroundcolor','white','callback',{@setTransparency_callback,dh},'string',num2str(1-gd.facealpha));
set(emptyOrFilledBgh,'selectionchangedfcn',{@shownRoiType_callback,emptyOrFilled,setTransparencyEH,dh});
set(showAllRoisBH,'callback',{@showAllRois_callback,drawonHoverlay,slider2Handle,sliceText2Handle,sliderMinTex2tHandle,sliderMaxText2Handle,emptyOrFilled,checkBoxOverlayH,setTransparencyEH,lazyTextHandle,framerateEH,movieButtonH,dh});
set(movieButtonH,'callback',{@saveStackToMovie_callback,drawonHoverlay,emptyOrFilled,showAllRoisBH,framerateEH,setTransparencyEH,lazyTextHandle,dh});
% panel 9, generate curve and fit
dataToAnalTextHandle=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[210 500 150 20],'string','Stack to analyze','horizontalalignment','left');
stackToAnalEditHandle=uicontrol('parent',ph(9),'style','edit','fontsize',10,'units','pixels','position',[210 480 100 20],'horizontalalignment','center','backgroundcolor','white');
curveSourceRBG=uibuttongroup('parent',ph(9),'fontsize',10,'units','pixels','position',[10 panelsz(2)-80 190 60],'title','Source of FRAP curve');
    curveSourceH(1)=uicontrol('parent',curveSourceRBG,'style','radiobutton','fontsize',10,'units','pixels','position',[10 10 80 20],'string','Images');
    curveSourceH(2)=uicontrol('parent',curveSourceRBG,'style','radiobutton','fontsize',10,'units','pixels','position',[100 10 80 20],'string','Data');
vertSizeOfNormGroup=195;
normalizationPh=uipanel('parent',ph(9),'fontsize',10,'units','pixels','position',[10 265 panelsz(1)-20 vertSizeOfNormGroup],'title','Normalization');
    normalizationTexts={'No normalization: B(t)','Background subtraction: N1(t) = B(t)-Bg(t)','Norm. to prebleach: N2(t) = N1(t) / N1(0)','Double normalization: N3(t) = N2(t) * (T(0)-Bg(0)) / (T(t)-Bg(t))','Triple normalization: N4(t) = 1 - (1-N3(t)) / (1-N3(0))'};
    normalizationTexts2=cell(5,1);
    normalizationTexts2{1}{1}='The fluorescence intensity of the bleached ROI is plotted.';
    normalizationTexts2{1}{2}='I(t)=B(t)';
    normalizationTexts2{1}{3}='I(t) - intensity to be plotted';
    normalizationTexts2{1}{4}='B(t) - intensity of bleached ROI';
    normalizationTexts2{2}{1}='The fluorescence intensity of the background is subtracted from the intensity of the bleached ROI.';
    normalizationTexts2{2}{2}='N1(t) = B(t)-Bg(t)';
    normalizationTexts2{2}{3}='B(t) - intensity of bleached ROI';
    normalizationTexts2{2}{4}='Bg(t) - background intensity';
    normalizationTexts2{3}{1}='The background-corrected intensity of the bleached ROI is normalized to the prebleach value.';
    normalizationTexts2{3}{2}='N2(t) = N1(t) / N1(0)';
    normalizationTexts2{3}{3}='N1(t), N1(0) - background-corrected intensity of the bleached ROI at t and before bleaching, respectively';
    normalizationTexts2{4}{1}='The background-corrected intensity of the bleached ROI is normalized to the prebleach value and to the total intensity of the unbleached ROI.';
    normalizationTexts2{4}{2}='N3(t) = N2(t) * (T(0)-Bg(0)) / (T(t)-Bg(t))';
    normalizationTexts2{4}{3}='N3(t) - double-normalized intensity';
    normalizationTexts2{4}{4}='T(t), T(0) - total intensity of the unbleached ROI at t and before bleaching, respectively';
    normalizationTexts2{4}{5}='Bg(t), Bg(0) - background intensity at t and before bleaching, respectively';
    normalizationTexts2{5}{1}='Triple normalization: The double normalized intensity is further normalized so that the prebleach and first post-bleach intensities are 1 and 0, respectively.';
    normalizationTexts2{5}{2}='N4(t) = 1 - (1-N3(t)) / (1-N3(0))';
    normalizationTexts2{5}{3}='N4(t) - triple-normalized intensity';
    normalizationTexts2{5}{4}='N3(t), N3(0) - double-normalized intensity at t and before bleaching, respectively.';
    normalizationPopupH=uicontrol('parent',normalizationPh,'style','popupmenu','fontsize',9,'units','pixels','position',[10 vertSizeOfNormGroup-45 panelsz(1)-40 20],'string',normalizationTexts);
    normalizationTextH=uicontrol('parent',normalizationPh,'style','text','fontsize',9,'units','pixels','position',[10 5 panelsz(1)-40 vertSizeOfNormGroup-60],'horizontalalignment','left','foregroundcolor','blue','String',normalizationTexts2{1});
set(curveSourceRBG,'selectionchangedfcn',{@changeCurveSource,dataToAnalTextHandle,curveSourceH,normalizationPopupH});
heightOfOneRow=30;
resultOfFitTextH=gobjects(7,1);
topOfFields=215;
resultOfFitTextH(1)=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[80 topOfFields+20 70 20],'string','Estimate','horizontalalignment','center');
resultOfFitTextH(2)=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[170 topOfFields+20 150 20],'string','95% confidence interval','horizontalalignment','center');
rowLabels={'Immob. fr.','t1','t2','f1','Bl. extent','Io'};
rowFonts={'Arial','Symbol','Symbol','Arial','Arial','Arial'};
for i=1:6
    switch i
        case {2,3}
            textToShow.text=rowLabels{i};
            textToShow.formatting={{[1 1],'size',10,'font','symbol'},{[2 2],'size',8,'shifty',-5,'shiftx',-2}};
            textToShow.position=[37 topOfFields-(i-1)*heightOfOneRow];
            formattedText(textToShow,ph(9));
        case {4,6}
            textToShow.text=rowLabels{i};
            textToShow.formatting={{[1 1],'size',10},{[2 2],'size',8,'shifty',-5,'shiftx',-2}};
            textToShow.position=[37 topOfFields-(i-1)*heightOfOneRow];
            formattedText(textToShow,ph(9));
        otherwise
            resultOfFitTextH(i+2)=uicontrol('parent',ph(9),'style','text','fontsize',10,'fontname',rowFonts{i},'units','pixels','position',[10 topOfFields-(i-1)*heightOfOneRow 70 20],'string',rowLabels{i},'horizontalalignment','center');
    end
end
resultOfFitH=gobjects(6,3);
for i=1:6
    resultOfFitH(i,1)=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[80 topOfFields-(i-1)*heightOfOneRow 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
    if i<=5
        for j=1:3
            resultOfFitH(i,2)=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[170 topOfFields-(i-1)*heightOfOneRow 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
            resultOfFitH(i,3)=uicontrol('parent',ph(9),'style','text','fontsize',10,'units','pixels','position',[250 topOfFields-(i-1)*heightOfOneRow 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
        end
    end
end
set(normalizationPopupH,'callback',{@normalizationPopup_callback,normalizationTextH,normalizationTexts2});
plotButtonH=uicontrol('parent',ph(9),'style','pushbutton','fontsize',10,'units','pixels','position',[panelsz(1)/4-smallBtnsz(1)/2 20 smallBtnsz],'backgroundcolor',blueColorDef,'string','Plot');
exportButtonH=uicontrol('parent',ph(9),'style','pushbutton','fontsize',10,'units','pixels','position',[3*panelsz(1)/4-smallBtnsz(1)/2 20 smallBtnsz],'backgroundcolor',blueColorDef,'string','Export results','callback',{@export_callback,'main',0,0,dh},'enable','off');
set(plotButtonH,'callback',{@plot_callback,stackToAnalEditHandle,normalizationPopupH,resultOfFitH,exportButtonH,bh,lazyTextHandle,curveSourceH,dh});
% end of panel definitions
set([drawonHbleach,drawonHmembrane,drawonHbg],'callback',{@drawOnH_callback,[drawonHbleach,drawonHmembrane,drawonHbg]});
for i=1:9
    set(bh(i),'callback',{@button_callback,dh,i,[bleachRoiSource;membraneRoiSource;bgRoiSource],bh(1:9)});
end
set(bh(10),'callback',{@Update_callback});
guidata(dh,gd);
setPanelVisibility(1,dh);
set(bh,'enable','on');
set([readImagesButtonHandle,inputForReadStack,loadDoitH,inputForReadCziImage,inputForReadCziRoi,readCziDoitH],'enable','on');
set(dh,'buttondownfcn',{@switchToActive_callback,dh});

function changeCurveSource(src,evt,dataToAnalTextHandle,curveSourceH,normalizationPopupH)
whichButton=find(cellfun(@(x) x,get(curveSourceH,'value')));
switch whichButton
    case 1 % images
        set(dataToAnalTextHandle,'string','Stack to analyze');
        set(normalizationPopupH,'enable','on');
    case 2 % data
        set(dataToAnalTextHandle,'string','Variable to analyze');
        set(normalizationPopupH,'enable','off');
end

function normalizationPopup_callback(src,evt,normalizationTextH,normalizationTexts2)
whichValue=get(src,'value');
set(normalizationTextH,'string',normalizationTexts2{whichValue});
% I have no idea why the following lines were ever needed.
%switch whichValue
%    case {1,2,3,4,5}
%        onRangeForTextH=1:7;
%        onRangeForEditH=1:5;
%end
%set(resultOfFitTextH(ismember(1:size(resultOfFitTextH,1),onRangeForTextH)),'visible','on');
%set(resultOfFitTextH(~ismember(1:size(resultOfFitTextH,1),onRangeForTextH)),'visible','off');
%onHandles=resultOfFitH(ismember(1:size(resultOfFitH,1),onRangeForEditH),:);
%onHandles=onHandles(ishandle(onHandles));
%set(onHandles,'visible','on');
%offHandles=resultOfFitH(~ismember(1:size(resultOfFitH,1),onRangeForEditH),:);
%offHandles=offHandles(ishandle(offHandles));
%set(offHandles,'visible','off');

function displayTimedMessage(text,objecthandle,duration,handleOfMain)
guiTempData=guidata(handleOfMain);
if guiTempData.handleoftimer~=0 && isobject(guiTempData.handleoftimer)
    try
        stop(guiTempData.handleoftimer);
        delete(guiTempData.handleoftimer);
    end
end
set(objecthandle,'string',text);
drawnow;
th=timer('TimerFcn',{@timercallback,objecthandle,handleOfMain},'StartDelay',duration);
start(th);
guiTempData.handleoftimer=th;
guidata(handleOfMain,guiTempData);

function timercallback(src,evt,objecthandle,handleOfMain)
if ishandle(handleOfMain)
    guiTempData=guidata(handleOfMain);
    if ishandle(objecthandle)
        set(objecthandle,'string','Nothing to do');
        drawnow;
    end
    if guiTempData.handleoftimer~=0 && isobject(guiTempData.handleoftimer)
        stop(src);
        delete(src);
        guiTempData.handleoftimer=0;
    end
    guidata(handleOfMain,guiTempData);
end

function changeMessagePermanently(lth,newText,handleOfMain)
guitempdata=guidata(handleOfMain);
set(lth,'string',newText);
drawnow;
if guitempdata.handleoftimer~=0 && ishandle(guitempdata.handleoftimer)
    stop(guiTempData.handleoftimer);
    delete(guiTempData.handleoftimer);
end
guitempdata.handleoftimer=0;
guidata(handleOfMain,guitempdata);


function saveStackToMovie_callback(src,evt,drawonHoverlay,emptyOrFilled,showAllRoisBH,framerateEH,setTransparencyEH,lth,handleOfMain)
guitempdata=guidata(handleOfMain);
drawonName=get(drawonHoverlay,'string');
if isempty(drawonName)
    errordlg('Name of image to draw on is empty','Oops','modal');
    return;
end
try
    overlayImage=evalin('base',drawonName);
catch
    errordlg('Error reading image to draw on.','Oops','modal');
    return;
end
if isempty(guitempdata.bleachRoi) && isempty(guitempdata.membraneRoi) && isempty(guitempdata.bgRoi)
    errordlg('All three ROIs are empty.','Oops','modal');
    return;
end
overlayImageData=double(overlayImage);
errorFound=checkRoiSizes(guitempdata,size(overlayImageData)); % guitempdata mask images are dipimages, overlayImageData is double. The size of the latter will be inverted by 'checkRoiSizes'
if errorFound
    return;
end
frmRt=guitempdata.framerate;
minScaleValue=prctile(overlayImageData(:),1);
maxScaleValue=prctile(overlayImageData(:),99);
whichButton=find(cellfun(@(x) x,get(emptyOrFilled,'value')));
defPath=guitempdata.resultfilepath;
[fileName,newPath]=uiputfile('*.avi','Save movie as',defPath);
if fileName~=0
    set(guitempdata.mainbuttonhandles,'enable','off');
    set(drawonHoverlay,'enable','off');
    set(emptyOrFilled,'enable','off');
    set(showAllRoisBH,'enable','off');
    set(framerateEH,'enable','off');
    set(setTransparencyEH,'enable','off');
    set(src,'enable','off');
    changeMessagePermanently(lth,'Saving movie...',handleOfMain);
    drawnow;
    fullFileName=[newPath,fileName];
    videoObj=VideoWriter(fullFileName,'Uncompressed AVI');
    videoObj.FrameRate=frmRt;
    open(videoObj);
    fh=figure;
    axisH=gca;
    for i=1:size(overlayImageData,3)
        imageToDisplay=squeeze(overlayImageData(:,:,i));
        ih=imshow(imageToDisplay,[minScaleValue maxScaleValue],'parent',axisH);
        hold on;
        drawAllRois(guitempdata.bleachRoiStruct,guitempdata.membraneRoiStruct,guitempdata.bgRoiStruct,axisH,guitempdata.bleachRoi,guitempdata.membraneRoi,guitempdata.bgRoi,...
            guitempdata.bleachRoiImageType,guitempdata.membraneRoiImageType,guitempdata.bgRoiImageType,whichButton,guitempdata.facealpha,i);
        set(ih,'CDataMapping','scaled');
        set(gca,'visible','off');
        set(gca,'dataaspectratio',[size(imageToDisplay),1]);
        currFrame=getframe(axisH);
        writeVideo(videoObj,currFrame);
    end
    close(videoObj);
    guitempdata.resultfilepath=newPath;
    assignin('base','resultfilepath_frapfit',newPath);
    if ishandle(fh)
        delete(fh);
    end
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    msgbox('Movie saved.','I''m done','modal');
    uiwait;
    set(guitempdata.mainbuttonhandles,'enable','on');
    set(drawonHoverlay,'enable','on');
    set(emptyOrFilled,'enable','on');
    set(showAllRoisBH,'enable','on');
    set(framerateEH,'enable','on');
    set(setTransparencyEH,'enable','on');
    set(src,'enable','on');
end

function setFrameRate_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
newFrameRate=str2double(get(src,'string'));
if newFrameRate<0
    set(src,'string',num2str(guitempdata.framerate));
else
    guitempdata.framerate=newFrameRate;
end
guidata(handleOfMain,guitempdata);

function setTransparency_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
newAlpha=str2double(get(src,'string'));
if newAlpha<0 || newAlpha>1
    set(src,'string',num2str(guitempdata.facealpha));
else
    guitempdata.facealpha=1-newAlpha;
    set(guitempdata.legendH,'facealpha',guitempdata.facealpha);
end
guidata(handleOfMain,guitempdata);

function plot_callback(src,evt,stackToAnalEditHandle,normalizationPopupH,resultOfFitH,exportButtonH,mainButtonHs,lazyTextHandle,curveSourceH,handleOfMain)
yellowColorDef=[240/255 240/255 60/255];
blueColorDef=[121/255 158/255 231/255];
curveSource=find(cellfun(@(x) x,get(curveSourceH,'value')));
varName=get(stackToAnalEditHandle,'string');
if isempty(varName)
    if curveSource==1
        errordlg('Name of stack is empty.','Oops','modal');
    else
        errordlg('Name of variable is empty.','Oops','modal');
    end
    return;
end
try
    if curveSource==1
        stack=evalin('base',varName);
    else
        curveData=evalin('base',varName);
    end
catch
    if curveSource==1
        errordlg('Error reading stack.','Oops','modal');
    else
        errordlg('Error reading variable.','Oops','modal');
    end
    return;
end
if curveSource==2
    if size(curveData,2)~=1 || numel(size(curveData))~=2
        errordlg('The imported FRAP curve must be a one-column array.','Oops','modal');
        return;
    end
end
guitempdata=guidata(handleOfMain);
guitempdata.a=[]; % delete a to let the program know that a new fitting has been started
switch curveSource
    case 1 % stack
        set(lazyTextHandle,'string','Calculating curve');
        drawnow;
        whichButton=get(normalizationPopupH,'value');
        if isempty(guitempdata.bleachRoi)
            errordlg('Bleach ROI hasn''t been defined.','Oops','modal');
            return;
        end
        if isempty(guitempdata.membraneRoi) && ismember(whichButton,[4 5])
            errordlg('Unbleached ROI hasn''t been defined.','Oops','modal');
            return;
        end
        if isempty(guitempdata.bgRoi) && ismember(whichButton,[2 3 4 5])
            errordlg('Background ROI hasn''t been defined.','Oops','modal');
            return;
        end
        if ismember(whichButton,[2,3,4,5])
            if sum([size(guitempdata.bleachRoi,1),size(guitempdata.bleachRoi,2)]==[size(guitempdata.bgRoi,1),size(guitempdata.bgRoi,2)])~=2
                errordlg('Bleaching and background ROIs aren''t of the same size.','Oops','modal');
                return;
            end
            if guitempdata.bgRoiImageType==2 && size(guitempdata.bgRoi,3)~=size(stack,3)
                errordlg('3D background ROI has different number of slices than the stack to be analyzed.','Oops','modal');
                return;
            end
        end
        if ismember(whichButton,[4,5])
            if sum([size(guitempdata.bleachRoi,1),size(guitempdata.bleachRoi,2)]==[size(guitempdata.membraneRoi,1),size(guitempdata.membraneRoi,2)])~=2
                errordlg('Bleaching and unbleached ROIs aren''t of the same size.','Oops','modal');
                return;
            end
            if guitempdata.membraneRoiImageType==2 && size(guitempdata.membraneRoi,3)~=size(stack,3)
                errordlg('3D unbleached ROI has different number of slices than the stack to be analyzed.','Oops','modal');
                return;
            end
        end
        if sum([size(guitempdata.bleachRoi,1),size(guitempdata.bleachRoi,2)]==[size(stack,1),size(stack,2)])~=2
            errordlg('ROIs aren''t of the same size as the stack to be analyzed.','Oops','modal');
            return;
        end
        if guitempdata.bleachRoiImageType==2 && size(guitempdata.bleachRoi,3)~=size(stack,3)
            errordlg('3D bleach ROI has different number of slices than the stack to be analyzed.','Oops','modal');
            return;
        end
        disableFit=0;
        if ismember(whichButton,[4,5])
            guitempdata.membraneRoi=guitempdata.membraneRoi&~guitempdata.bleachRoi; % eliminates pixels belonging to the bleach ROI from the membrane (unbleached) ROI
            if size(guitempdata.membraneRoi,3)>1
                membraneMaskStack=guitempdata.membraneRoi;
            else
                membraneMaskStack=double(guitempdata.membraneRoi);
                membraneMaskStack=dip_image(membraneMaskStack(:,:,ones(size(stack,3),1)));
            end
            tot=squeeze(double(sum(sum(stack*membraneMaskStack,[],1),[],2)))./squeeze(double(sum(sum(membraneMaskStack,[],1),[],2)));
            if sum(isnan(tot))~=0
                disableFit=disableFit+1;
            end
        else
            tot=nan;
        end
        if ismember(whichButton,[2,3,4,5])
            if size(guitempdata.bgRoi,3)>1
                bgMaskStack=guitempdata.bgRoi;
            else
                bgMaskStack=double(guitempdata.bgRoi);
                bgMaskStack=dip_image(bgMaskStack(:,:,ones(size(stack,3),1)));
            end
            bg=squeeze(double(sum(sum(stack*bgMaskStack,[],1),[],2)))./squeeze(double(sum(sum(bgMaskStack,[],1),[],2)));
            if sum(isnan(bg))~=0
                disableFit=disableFit+2;
            end
        else
            bg=nan;
        end
        if size(guitempdata.bleachRoi,3)>1
            bleachMaskStack=guitempdata.bleachRoi;
        else
            bleachMaskStack=double(guitempdata.bleachRoi);
            bleachMaskStack=dip_image(bleachMaskStack(:,:,ones(size(stack,3),1)));
        end
        bl=squeeze(double(sum(sum(stack*bleachMaskStack,[],1),[],2)))./squeeze(double(sum(sum(bleachMaskStack,[],1),[],2)));
        if sum(isnan(bl))~=0
            disableFit=disableFit+4;
        end
        if disableFit~=0
            binaryDisableFit=dec2bin(disableFit,3);
            disableFitMessages=cell(1,3);
            if binaryDisableFit(1)=='1' % bleached
                disableFitMessages{1}='bleached';
            end
            if binaryDisableFit(2)=='1' % bg
                disableFitMessages{2}='background';
            end
            if binaryDisableFit(3)=='1' % unbleached
                disableFitMessages{3}='unbleached';
            end
            whichIsNotEmptyIndex=find(~cellfun(@isempty,disableFitMessages));
            if numel(whichIsNotEmptyIndex)==1
                disableFitFinalMessage=disableFitMessages{whichIsNotEmptyIndex};
                curveText='curve';
            else
                disableFitFinalMessage='';
                for ii=1:numel(whichIsNotEmptyIndex)
                    if ii==numel(whichIsNotEmptyIndex)-1
                        disableFitFinalMessage=[disableFitFinalMessage,disableFitMessages{whichIsNotEmptyIndex(ii)},' and '];
                    elseif ii==numel(whichIsNotEmptyIndex)
                        disableFitFinalMessage=[disableFitFinalMessage,disableFitMessages{whichIsNotEmptyIndex(ii)}];
                    else
                        disableFitFinalMessage=[disableFitFinalMessage,disableFitMessages{whichIsNotEmptyIndex(ii)},', '];
                    end
                end
                curveText='curves';
            end
            errordlg(['There are non-sense (NaN) values in the ',disableFitFinalMessage,' ',curveText,', most likely because of non-existent ROIs in certain slices. Fitting will be disabled.'],'Oops','modal');
        end
        jumps=abs(diff(bl));
        firstBleachPos=find(jumps==max(jumps))+1;
        firstBleachPos=firstBleachPos(1);
        recoveryInterval=[firstBleachPos numel(bl)];
        prebleachInterval=[1 firstBleachPos-1];
        guitempdata.manuallySelectedPoints=true(numel(bl),1);
        frapCurve=normalizeFrapData(bl,bg,tot,recoveryInterval,prebleachInterval,whichButton,guitempdata.manuallySelectedPoints);
    case 2 % curve data
        frapCurve=curveData;
        guitempdata.manuallySelectedPoints=true(numel(frapCurve),1);
        jumps=abs(diff(frapCurve));
        firstBleachPos=find(jumps==max(jumps))+1;
        recoveryInterval=[firstBleachPos numel(frapCurve)];
        prebleachInterval=[1 firstBleachPos-1];
        whichButton=1;
        disableFit=0;
end
guitempdata.withinRangeFrapPoints=false(numel(frapCurve),1);
guitempdata.withinRangePreBleachPoints=false(numel(frapCurve),1);
guitempdata.withinRangeFrapPoints(recoveryInterval(1):recoveryInterval(2))=true;
guitempdata.withinRangePreBleachPoints(prebleachInterval(1):prebleachInterval(2))=true;
[editableH,enableStatus]=getEditableStuff(get(src,'parent'));
set(mainButtonHs,'enable','off');
set(editableH,'enable','off');
posOfMain=get(handleOfMain,'position');
sizeOfThis=[500 610];
posOfThis=[posOfMain(1)-sizeOfThis(1)-20 posOfMain(2) sizeOfThis];
if posOfThis(1)<0
    posOfThis(1)=10;
end
fh=figure('Name','Analyze FRAP curve','windowstyle','normal','toolbar','none','menubar','none','units','pixels','position',posOfThis,'color',[0.9412 0.9412 0.9412],'NumberTitle','off','resize','off');
set(handleOfMain,'closerequestfcn','');
set(fh,'closerequestfcn',{@reenableControls,src,editableH,enableStatus,exportButtonH,mainButtonHs,resultOfFitH,whichButton,handleOfMain,curveSource,varName,'figure'});
uicontrol('parent',fh,'style','text','units','pixel','fontsize',10,'position',[10 sizeOfThis(2)-30 70 20],'string','Intensity','horizontalalignment','center');
currentValueH=uicontrol('parent',fh,'style','text','units','pixel','fontsize',10,'position',[10 sizeOfThis(2)-50 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
uicontrol('parent',fh,'style','text','units','pixel','fontsize',10,'position',[100 sizeOfThis(2)-30 70 20],'string','X','horizontalalignment','center');
currentXH=uicontrol('parent',fh,'style','text','units','pixel','fontsize',10,'position',[100 sizeOfThis(2)-50 70 20],'horizontalalignment','center','backgroundcolor',yellowColorDef);
fitH=uicontrol('parent',fh,'style','pushbutton','fontsize',10,'units','pixels','position',[230 sizeOfThis(2)-50 70 30],'string','Fit','backgroundcolor',blueColorDef,'enable',onOff01(disableFit));
uicontrol('parent',fh,'style','pushbutton','fontsize',10,'units','pixels','position',[310 sizeOfThis(2)-50 90 30],'string','Export curves','backgroundcolor',blueColorDef,'callback',{@export_callback,'plot',whichButton,curveSource,handleOfMain});
uicontrol('parent',fh,'style','pushbutton','fontsize',10,'units','pixels','position',[410 sizeOfThis(2)-50 70 30],'string','Return','backgroundcolor',blueColorDef,'callback',{@reenableControls,src,editableH,enableStatus,exportButtonH,mainButtonHs,resultOfFitH,whichButton,handleOfMain,curveSource,varName,'button'});
fbgh=uibuttongroup('Parent',fh,'Title','Type of fit','FontSize',10,'Units','pixels','Position',[10 sizeOfThis(2)-105 150 50]);
    fitTypeRH(1)=uicontrol('Parent',fbgh,'Style','radiobutton','Units','pixels','Position',[10 10 60 20],'FontSize',10,'String','1-exp','Value',guitempdata.fitType==1);
    fitTypeRH(2)=uicontrol('Parent',fbgh,'Style','radiobutton','Units','pixels','Position',[80 10 60 20],'FontSize',10,'String','2-exp','Value',guitempdata.fitType==2);
rowLabels={'Extent of bleaching (a)','Recovery time constant (t1)','Recovery time constant (t2)','Fraction of 1st component (f1)','Immobile fraction'};
rowHeight=25;
distFromTop=130;
for i=1:5
    switch i
        case {2,3}
            textToShow.text=rowLabels{i};
            textToShow.formatting={{[1 24],'size',10},{[25 25],'size',10,'font','symbol'},{[26 26],'size',8,'shifty',-5,'shiftx',-2},{[27 27],'size',10}};
            textToShow.position=[24 sizeOfThis(2)-distFromTop-(i-1)*rowHeight];
            formattedText(textToShow,fh);
        case 4
            textToShow.text=rowLabels{i};
            textToShow.formatting={{[1 13],'size',10},{[14 15],'size',8,'shifty',5,'shiftx',-2},{[16 28],'size',10},{[29 29],'size',8,'shifty',-5,'shiftx',-2},{[30 30],'size',10}};
            textToShow.position=[13 sizeOfThis(2)-distFromTop-(i-1)*rowHeight];
            formattedText(textToShow,fh);
        otherwise
            uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[10 sizeOfThis(2)-distFromTop-(i-1)*rowHeight 180 20],'string',rowLabels{i},'horizontalalignment','right');
    end
end
uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[190 sizeOfThis(2)-distFromTop+20 40 20],'string','Const','horizontalalignment','center');
uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[230 sizeOfThis(2)-distFromTop+35 80 20],'string','Initial value/','horizontalalignment','center');
uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[230 sizeOfThis(2)-distFromTop+20 80 20],'string','Constant','horizontalalignment','center');
uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[320 sizeOfThis(2)-distFromTop+20 80 20],'string','Lower bound','horizontalalignment','center');
uicontrol('parent',fh,'style','text','fontsize',10,'units','pixels','position',[410 sizeOfThis(2)-distFromTop+20 80 20],'string','Upper bound','horizontalalignment','center');
initUpperLowerH=gobjects(5,3);
constantH=gobjects(5,1);
% initUpperLowerH(1,:) - a
% initUpperLowerH(2,:) - tau1
% initUpperLowerH(3,:) - tau2
% initUpperLowerH(4,:) - f1
% initUpperLowerH(5,:) - immob fr
% find initial values
[initialGuesses,bounds]=generateGuesses(guitempdata.fitType,frapCurve,prebleachInterval,recoveryInterval,guitempdata.manuallySelectedPoints);
% initialGuesses=[i0,a,immFract,tau1,tau2,f1]
% bounds - the same as initialGuesses, although i0 is not fitted
guitempdata.i0Guess=initialGuesses(1);
for i=1:5
    constantH(i)=uicontrol('parent',fh,'style','checkbox','fontsize',10,'units','pixels','position',[200 sizeOfThis(2)-distFromTop-(i-1)*rowHeight 30 20],'userdata',i,'value',guitempdata.constantParameter(i),'enable',onOff01(ismember(i,[3 4]) && guitempdata.fitType==1));
    for j=1:3
        initUpperLowerH(i,j)=uicontrol('parent',fh,'style','edit','fontsize',10,'units','pixels','position',[230+(j-1)*90 sizeOfThis(2)-distFromTop-(i-1)*rowHeight 80 20],'callback',{@initializechange_callback,i,j,handleOfMain});
        switch j
            case 1
                set(initUpperLowerH(i,j),'backgroundcolor',[148 190 228]/255);
                set(initUpperLowerH(i,j),'tooltip','Your initial guess for the parameter. A reasonable guess is provided when the plot window is opened for the first time. If the parameter is set to constant, this value is used in the model.');
                set(initUpperLowerH(i,j),'enable',onOff01(ismember(i,[3 4]) && guitempdata.fitType==1));
            case 2
                set(initUpperLowerH(i,j),'backgroundcolor',[254 198 206]/255);
                set(initUpperLowerH(i,j),'tooltip','The smallest allowed value of the parameter.');
                set(initUpperLowerH(i,j),'enable',onOff01((guitempdata.fitType==1 && ismember(i,[3 4])) || guitempdata.constantParameter(i)));
            case 3
                set(initUpperLowerH(i,j),'backgroundcolor',[201 251 209]/255);
                set(initUpperLowerH(i,j),'tooltip','The largest allowed value of the parameter.');
                set(initUpperLowerH(i,j),'enable',onOff01((guitempdata.fitType==1 && ismember(i,[3 4])) || guitempdata.constantParameter(i)));
        end
    end
end
guitempdata=updateInitialGuessesAndBounds(guitempdata,initialGuesses,bounds,initUpperLowerH);
set(constantH,'callback',{@constantbox_callback,initUpperLowerH,handleOfMain});
ah(1)=axes('parent',fh,'units','pixels','position',[40 100 sizeOfThis(1)-60 260],'nextplot','add');
ah(2)=axes('parent',fh,'units','pixels','position',[40 25 sizeOfThis(1)-60 40],'nextplot','add');
set(fitH,'callback',{@fit_callback,ah,resultOfFitH,lazyTextHandle,handleOfMain});
set(fbgh,'selectionchangedfcn',{@fitTypeChange_callback,fitTypeRH,constantH,initUpperLowerH,handleOfMain});
guitempdata.frapCurvePlotH=gobjects(numel(frapCurve),1);
for i=1:numel(frapCurve)
    guitempdata.frapCurvePlotH(i)=plot(i,frapCurve(i),'o','parent',ah(1));
    if (i>=prebleachInterval(1) && i<=prebleachInterval(2)) || (i>=recoveryInterval(1) && i<=recoveryInterval(2))
        set(guitempdata.frapCurvePlotH(i),'buttondownfcn',{@symbol_callback,i,ah,handleOfMain,curveSource,whichButton,initUpperLowerH});
    end
    setMarkerFaceEdgeColor(guitempdata.manuallySelectedPoints(i),guitempdata.withinRangeFrapPoints(i),guitempdata.withinRangePreBleachPoints(i),guitempdata.frapCurvePlotH(i));
end
ylim1=get(ah(1),'ylim');
set(ah(2),'xlim',get(ah(1),'xlim'));
guitempdata.lh(1)=line([prebleachInterval(1) prebleachInterval(1)],[ylim1(1) ylim1(2)],'parent',ah(1),'color','r','userdata',1);
guitempdata.lh(2)=line([prebleachInterval(2) prebleachInterval(2)],[ylim1(1) ylim1(2)],'parent',ah(1),'color','r','userdata',2);
guitempdata.lh(3)=line([recoveryInterval(1) recoveryInterval(1)],[ylim1(1) ylim1(2)],'parent',ah(1),'color','b','userdata',3);
guitempdata.lh(4)=line([recoveryInterval(2) recoveryInterval(2)],[ylim1(1) ylim1(2)],'parent',ah(1),'color','b','userdata',4);
set(ah(1),'ylim',ylim1);
set(guitempdata.lh,'buttondownfcn',{@lineMove_callback,handleOfMain});
set(fh,'WindowButtonUpFcn',{@lineMoveAndDraw_callback,currentValueH,currentXH,ah(1),handleOfMain,whichButton,curveSource,'up',initUpperLowerH});
set(fh,'WindowButtonMotionFcn',{@lineMoveAndDraw_callback,currentValueH,currentXH,ah(1),handleOfMain,whichButton,curveSource,'move',initUpperLowerH});
set(lazyTextHandle,'string','Nothing to do');
guitempdata.frapCurve=frapCurve;
if curveSource==1
    guitempdata.bl=bl;
    guitempdata.bg=bg;
    guitempdata.tot=tot;
else
    guitempdata.bl=nan;
    guitempdata.bg=nan;
    guitempdata.tot=nan;
end
guitempdata.recoveryInterval=recoveryInterval;
guitempdata.prebleachInterval=prebleachInterval;
guitempdata.fittedCurve='';
guitempdata.activewindow=fh;
guidata(handleOfMain,guitempdata);

function setMarkerFaceEdgeColor(isMarkerSelected,isMarkerInFrapRange,isMarkerInPreBleachRange,handleOfMarker)
if isMarkerInFrapRange 
    if isMarkerSelected
        set(handleOfMarker,'markerfacecolor',[0 0.4470 0.7410]);
        set(handleOfMarker,'markeredgecolor',[0 0.4470 0.7410]);
    else
        set(handleOfMarker,'markerfacecolor','none');
        set(handleOfMarker,'markeredgecolor',[0 0.4470 0.7410]);
    end
elseif isMarkerInPreBleachRange
    if isMarkerSelected
        set(handleOfMarker,'markerfacecolor',[0.3059 0.6902 0.3804]);
        set(handleOfMarker,'markeredgecolor',[0.3059 0.6902 0.3804]);
    else
        set(handleOfMarker,'markerfacecolor','none');
        set(handleOfMarker,'markeredgecolor',[0.3059 0.6902 0.3804]);
    end
else
    set(handleOfMarker,'markerfacecolor','none');
    set(handleOfMarker,'markeredgecolor',[0 0 0]);
end

function symbol_callback(srv,evt,symbolNumber,axisHandles,handleOfMain,curveSource,whichButton,initUpperLowerH)
gd=guidata(handleOfMain);
gd.manuallySelectedPoints(symbolNumber)=~gd.manuallySelectedPoints(symbolNumber);
guidata(handleOfMain,gd);
delete(gd.frapCurvePlotH(symbolNumber));
gd.frapCurvePlotH(symbolNumber)=plot(symbolNumber,gd.frapCurve(symbolNumber),'o','parent',axisHandles(1),'buttondownfcn',{@symbol_callback,symbolNumber,axisHandles,handleOfMain,curveSource,whichButton,initUpperLowerH});
setMarkerFaceEdgeColor(gd.manuallySelectedPoints(symbolNumber),gd.withinRangeFrapPoints(symbolNumber),gd.withinRangePreBleachPoints(symbolNumber),gd.frapCurvePlotH(symbolNumber));
[gd.frapCurve,gd.frapCurvePlotH,gd.withinRangeFrapPoints,gd.withinRangePreBleachPoints,gd.lh]=redrawCurveAndLines(gd.frapCurve,curveSource,gd.bl,gd.bg,gd.tot,gd.recoveryInterval,gd.prebleachInterval,whichButton,gd.manuallySelectedPoints,gd.frapCurvePlotH,gd.lh,axisHandles,handleOfMain,initUpperLowerH);
[initialGuesses,bounds]=generateGuesses(gd.fitType,gd.frapCurve,gd.prebleachInterval,gd.recoveryInterval,gd.manuallySelectedPoints);
gd.i0Guess=initialGuesses(1);
gd=updateInitialGuessesAndBounds(gd,initialGuesses,bounds,initUpperLowerH);
guidata(handleOfMain,gd);

function guitempdata=updateInitialGuessesAndBounds(guitempdata,initialGuesses,bounds,initUpperLowerH)
% field order: a, tau1, tau2, f1, IF
% guesses: i0,a,immFract,tau1,tau2,f1
fieldCodes=[2 4 5 6 3];
for i=1:5
    if ~isnan(initialGuesses(fieldCodes(i)))
        set(initUpperLowerH(i,1),'string',num2str(initialGuesses(fieldCodes(i))));
    else
        set(initUpperLowerH(i,1),'string','');
    end
    guitempdata.initializationParams(i,1)=initialGuesses(fieldCodes(i));
    if ~isnan(bounds(fieldCodes(i),1))
        set(initUpperLowerH(i,2),'string',num2str(bounds(fieldCodes(i),1)));
        set(initUpperLowerH(i,3),'string',num2str(bounds(fieldCodes(i),2)));
    else
        set(initUpperLowerH(i,2),'string','');
        set(initUpperLowerH(i,3),'string','');
    end
    guitempdata.initializationParams(i,2:3)=bounds(fieldCodes(i),:);
end

function [initialGuesses,bounds]=generateGuesses(fitType,frapCurve,prebleachInterval,recoveryInterval,manuallySelectedPoints)
% initialGuesses=[i0,a,immFract,tau1,tau2,f1]
initialGuesses=zeros(6,1);
bounds=zeros(6,2);
initialFrapCurve=frapCurve(prebleachInterval(1):prebleachInterval(2));
initialGuesses(1)=mean(initialFrapCurve(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
bounds(1,:)=[nan nan];
y=frapCurve(recoveryInterval(1):recoveryInterval(2));
initialGuesses(2)=round(initialGuesses(1)-y(1),3);
bounds(2,:)=[0 initialGuesses(1)];
initialGuesses(3)=round(1-(mean(y(end-3:end))-y(1))/initialGuesses(2),3);
if initialGuesses(3)<0
    initialGuesses(3)=0;
end
bounds(3,:)=[0 initialGuesses(1)];
switch fitType
    case 1 % 1-exp
        normY=(y-y(1))/max(y-y(1));
        filt=fspecial('average',[3 1]);
        normY(2:end-1)=filter2(filt,normY,'valid');
        zeroY=normY-(1-exp(-1));
        if ~isempty(find(diff(sign(zeroY)),1))
            initialGuesses(4)=find(diff(sign(zeroY)),1);
        else
            initialGuesses(4)=numel(frapCurve)/2;
        end
        if isempty(initialGuesses(4))
            initialGuesses(4)=1;
        end
        initialGuesses(5:6)=[nan nan];
    case 2 % 2-exp
        normY=log(1-(y-y(1))/max(y-y(1)));
        xScaleForGuess=(0:numel(normY)-1)';
        xScaleForGuess(isnan(normY) | isinf(normY))=[];
        normY(isnan(normY) | isinf(normY))=[];
        boundaryOfParts=round(numel(normY)/4);
        fitmodelGuessLine=fittype('a*x');
        tauGuess1=fit(xScaleForGuess(1:boundaryOfParts),normY(1:boundaryOfParts),fitmodelGuessLine,'startpoint',normY(boundaryOfParts)/xScaleForGuess(boundaryOfParts));
        initialGuesses(4)=round(-1/tauGuess1.a,1);
        tauGuess2=fit(xScaleForGuess(boundaryOfParts:end),normY(boundaryOfParts:end),fitmodelGuessLine,'startpoint',normY(end)/xScaleForGuess(end));
        initialGuesses(5)=round(-1/tauGuess2.a);
        if isempty(initialGuesses(4))
            initialGuesses(4)=1;
        end
        if isempty(initialGuesses(5))
            initialGuesses(5)=1;
        end
        initialGuesses(6)=0.5;
end
bounds(4,:)=[0 recoveryInterval(2)-recoveryInterval(1)];
bounds(5,:)=[0 recoveryInterval(2)-recoveryInterval(1)];
bounds(6,:)=[0 1];

function fitTypeChange_callback(src,evt,fitTypeRH,constantH,initUpperLowerH,handleOfMain)
gd=guidata(handleOfMain);
switch find(cell2mat(get(fitTypeRH,'value')))
    case 1 % 1-exp
        set(constantH(3:4),'enable','off');
        set(initUpperLowerH(3:4,:),'enable','off');
        gd.fitType=1;
    case 2 % 2-exp
        set(constantH(3:4),'enable','on');
        set(initUpperLowerH(3:4,:),'enable','on');
        gd.fitType=2;
end
[initialGuesses,bounds]=generateGuesses(gd.fitType,gd.frapCurve,gd.prebleachInterval,gd.recoveryInterval,gd.manuallySelectedPoints);
gd=updateInitialGuessesAndBounds(gd,initialGuesses,bounds,initUpperLowerH);
guidata(handleOfMain,gd);

function constantbox_callback(src,evt,initUpperLowerH,handleOfMain)
gd=guidata(handleOfMain);
whichParamter=get(src,'userdata');
switch get(src,'value')
    case true % constant
        set(initUpperLowerH(whichParamter,2:3),'enable','off');
        gd.constantParameter(whichParamter)=true;
    case false
        set(initUpperLowerH(whichParamter,2:3),'enable','on');
        gd.constantParameter(whichParamter)=false;
end
guidata(handleOfMain,gd);

function initializechange_callback(src,evt,i,j,handleOfMain)
gd=guidata(handleOfMain);
gd.initializationParams(i,j)=str2double(get(src,'string'));
guidata(handleOfMain,gd);

function textOnOff=onOff01(numOnOff)
% returns 'off' if numOnOff is true
if numOnOff~=0
    textOnOff='off';
else
    textOnOff='on';
end

function fit_callback(src,evt,axisH,resultOfFitH,lth,handleOfMain)
% resultOfFitH: 1 - immobile fraction, 2 - tau1,  3 - tau2, 4 - f1, 5 - a, 6 - I0
% initializationParams, (1,:) - a; (2,:) - tau1; (3,:) - tau2; (4,:) - f1; (5,:) - immobile fraction
guitempdata=guidata(handleOfMain);
switch guitempdata.fitType
    case 1 % 1-exp
        parameterNames{1}='extent of bleaching';
        parameterNames{2}='recovery time constant_1';
        parameterNames{3}='immobile fraction';
        numOfParameters=3;
        locationInParamList=[1 2 5];
        locationInResultList=[5 2 1];
        allPotencialCoefficients={'a','tau','immFract'};
        actualCoefficients=allPotencialCoefficients(~guitempdata.constantParameter(locationInParamList));
        fixedParameters=allPotencialCoefficients(guitempdata.constantParameter(locationInParamList));
        allGuesses=guitempdata.initializationParams(locationInParamList,1);
        allLowerBounds=guitempdata.initializationParams(locationInParamList,2);
        allUpperBounds=guitempdata.initializationParams(locationInParamList,3);
        f=fittype('i0-a+(1-immFract)*a*(1-exp(-t/tau))','independent','t','problem',['i0',fixedParameters],'coefficients',actualCoefficients);
    case 2 % 2-exp
        parameterNames{1}='extent of bleaching';
        parameterNames{2}='recovery time constant_1';
        parameterNames{3}='recovery time constant_2';
        parameterNames{4}='fraction of 1st component';
        parameterNames{5}='immobile fraction';
        numOfParameters=5;
        locationInParamList=[1 2 3 4 5];
        locationInResultList=[5 2 3 4 1];
        allPotencialCoefficients={'a','tau1','tau2','f1','immFract'};
        actualCoefficients=allPotencialCoefficients(~guitempdata.constantParameter(locationInParamList));
        fixedParameters=allPotencialCoefficients(guitempdata.constantParameter(locationInParamList));
        allGuesses=guitempdata.initializationParams(locationInParamList,1);
        allLowerBounds=guitempdata.initializationParams(locationInParamList,2);
        allUpperBounds=guitempdata.initializationParams(locationInParamList,3);
        f=fittype('i0-a+(1-immFract)*a*(f1*(1-exp(-t/tau1))+(1-f1)*(1-exp(-t/tau2)))','independent','t','problem',['i0',fixedParameters],'coefficients',actualCoefficients);
end
problemList=false(numOfParameters,1);
for i=1:numOfParameters
    if guitempdata.initializationParams(locationInParamList(i),1)>guitempdata.initializationParams(locationInParamList(i),3) || guitempdata.initializationParams(locationInParamList(i),1)<guitempdata.initializationParams(locationInParamList(i),2) || guitempdata.initializationParams(locationInParamList(i),2)>guitempdata.initializationParams(locationInParamList(i),3)
        problemList(i)=true;
    end
end
if sum(problemList)>0
    errorTextToShow=['The following parameters don''t satisfy the condition: Lower bound <= Initial value <= Upper bound',newline];
    problemParameterList=parameterNames(problemList);
    problemParameterList=cellfun(@(x) [x,', '],problemParameterList,'UniformOutput',false);
    problemParameterList=cell2mat(problemParameterList);
    errorTextToShow=[errorTextToShow,problemParameterList(1:end-2)];
    errordlg(errorTextToShow,'Oops','modal');
    return;
end
changeMessagePermanently(lth,'Fitting...',handleOfMain);
drawnow;
try
    fittedFunctionXScale=(0:numel(guitempdata.frapCurve)-guitempdata.recoveryInterval(1))';
    plotXScale=guitempdata.recoveryInterval(1):numel(guitempdata.frapCurve);
    fitXScale=(0:guitempdata.recoveryInterval(2)-guitempdata.recoveryInterval(1))';
    y=guitempdata.frapCurve(guitempdata.recoveryInterval(1):guitempdata.recoveryInterval(2));
    indicesOfPointsIn=guitempdata.manuallySelectedPoints(guitempdata.recoveryInterval(1):guitempdata.recoveryInterval(2));
    fitXScale=fitXScale(indicesOfPointsIn);
    y=y(indicesOfPointsIn);
    actualGuesses=allGuesses(~guitempdata.constantParameter(locationInParamList));
    actualLowerBounds=allLowerBounds(~guitempdata.constantParameter(locationInParamList));
    actualUpperBounds=allUpperBounds(~guitempdata.constantParameter(locationInParamList));
    actualProblemValues=[guitempdata.i0Guess,allGuesses(guitempdata.constantParameter(locationInParamList))];
    actualProblemValues=num2cell(actualProblemValues);
    % coeffnames: a, tau, immFract (single-exp)
    % coeffnames: a, tau1, tau2, f1, immFract (double-exp)
    fo=fitoptions('method','nonlinearleastsquares','startpoint',actualGuesses,'lower',actualLowerBounds,'upper',actualUpperBounds);
    fr=fit(fitXScale,y,f,fo,'problem',actualProblemValues);
catch
    displayTimedMessage('Fitting error',lth,3,handleOfMain);
    guitempdata.fitSuccess=false;
    guidata(handleOfMain,guitempdata);
    errordlg('Fittng problem. Try changing the fitted range, the pre-bleach range, the initial values or the lower/upper bounds.','Oops');
    return;
end
confIntervals=confint(fr);
guitempdata.fittedParameters=zeros(numOfParameters,1);
guitempdata.confIntervals=zeros(numOfParameters,2);
set(resultOfFitH(1:5,:),'string','');
set(resultOfFitH(6,1),'string',formatNumberMyWay(guitempdata.i0Guess,3,9));
for i=1:numOfParameters
    if guitempdata.constantParameter(locationInParamList(i))
        guitempdata.fittedParameters(i)=actualProblemValues{1+sum(guitempdata.constantParameter(locationInParamList(1:i)))};
        guitempdata.confIntervals(i,:)=[nan nan];
    else
        guitempdata.fittedParameters(i)=fr.(actualCoefficients{sum(~guitempdata.constantParameter(locationInParamList(1:i)))});
        guitempdata.confIntervals(i,:)=confIntervals(:,sum(~guitempdata.constantParameter(locationInParamList(1:i))))';
    end
    set(resultOfFitH(locationInResultList(i),1),'string',formatNumberMyWay(guitempdata.fittedParameters(i),3,9));
    set(resultOfFitH(locationInResultList(i),2),'string',formatNumberMyWay(guitempdata.confIntervals(i,1),3,9));
    set(resultOfFitH(locationInResultList(i),3),'string',formatNumberMyWay(guitempdata.confIntervals(i,2),3,9));
end
guitempdata.i0=guitempdata.i0Guess;
if ishandle(guitempdata.frapFitCurvePlotH)
    delete(guitempdata.frapFitCurvePlotH);
end
guitempdata.fittedCurve=fitfunction(guitempdata.fittedParameters,guitempdata.i0,fittedFunctionXScale,guitempdata.fitType);
guitempdata.frapFitCurvePlotH=plot(plotXScale,guitempdata.fittedCurve,'color','r','parent',axisH(1),'linewidth',2);
if ishandle(guitempdata.residualPlotH)
    delete(guitempdata.residualPlotH);
end
guitempdata.residualCurve=guitempdata.frapCurve(guitempdata.recoveryInterval(1):end)-guitempdata.fittedCurve;
guitempdata.residualPlotH=plot(plotXScale,guitempdata.residualCurve,'color','r','parent',axisH(2));
set(axisH(2),'xlim',get(axisH(1),'xlim'));
guitempdata.fitSuccess=true;
guitempdata.allPotencialCoefficients=allPotencialCoefficients;
guitempdata.constantInCurrentModel=guitempdata.constantParameter(locationInParamList);
guitempdata.fitTypeCompleted=guitempdata.fitType;
guidata(handleOfMain,guitempdata);
displayTimedMessage('Fitting completed',lth,3,handleOfMain);

function y=fitfunction(params,i0,t,eqnType)
switch eqnType
    case 1 % 1-exp
        a=params(1);
        tau=params(2);
        immFract=params(3);
        y=i0-a+(1-immFract)*a*(1-exp(-t/tau));
    case 2 % 2-exp
        a=params(1);
        tau1=params(2);
        tau2=params(3);
        f1=params(4);
        immFract=params(5);
        y=i0-a+(1-immFract)*a*(f1*(1-exp(-t/tau1))+(1-f1)*(1-exp(-t/tau2)));
end

function lineMoveAndDraw_callback(src,evt,currentValueH,currentXH,ah,handleOfMain,whichButton,curveSource,currentAction,initUpperLowerH)
if ishandle(handleOfMain)
    guitempdata=guidata(handleOfMain);
    if guitempdata.whichLineClicked~=0
        cp=get(ah,'currentpoint');
        lastClick=[cp(1,1) cp(1,2)];
        xOfLine=round(lastClick(1));
        lengthOfArray=numel(guitempdata.frapCurve);
        if xOfLine<1
            xOfLine=1;
        end
        if xOfLine>lengthOfArray
            xOfLine=lengthOfArray;
        end
        switch guitempdata.whichLineClicked
            case 1
                if xOfLine>=guitempdata.prebleachInterval(2)-1
                    xOfLine=guitempdata.prebleachInterval(2);
                end
                guitempdata.prebleachInterval(1)=xOfLine;
                colorOfLine='r';
            case 2
                if xOfLine<=guitempdata.prebleachInterval(1)+1
                    xOfLine=guitempdata.prebleachInterval(1);
                end
                if xOfLine>=guitempdata.recoveryInterval(1)
                    xOfLine=guitempdata.recoveryInterval(1)-1;
                end
                guitempdata.prebleachInterval(2)=xOfLine;
                colorOfLine='r';
            case 3
                if xOfLine>guitempdata.recoveryInterval(2)-1
                    xOfLine=guitempdata.recoveryInterval(2)-1;
                end
                if xOfLine<=guitempdata.prebleachInterval(2)
                    xOfLine=guitempdata.prebleachInterval(2)+1;
                end
                guitempdata.recoveryInterval(1)=xOfLine;
                colorOfLine='b';
            case 4
                if xOfLine<guitempdata.recoveryInterval(1)+1
                    xOfLine=guitempdata.recoveryInterval(1)+1;
                end
                guitempdata.recoveryInterval(2)=xOfLine;
                colorOfLine='b';
        end
        set(currentValueH,'string',num2str(guitempdata.frapCurve(xOfLine)));
        set(currentXH,'string',num2str(xOfLine));
        
        if strcmp(currentAction,'up')
            guitempdata.whichLineClicked=0;
            guidata(handleOfMain,guitempdata); % this is required to set whichLineClicked immediately to zero so that this part of the callback is not reached again
            guitempdata.withinRangeFrapPoints=false(numel(guitempdata.frapCurve),1);
            guitempdata.withinRangePreBleachPoints=false(numel(guitempdata.frapCurve),1);
            guitempdata.withinRangeFrapPoints(guitempdata.recoveryInterval(1):guitempdata.recoveryInterval(2))=true;
            guitempdata.withinRangePreBleachPoints(guitempdata.prebleachInterval(1):guitempdata.prebleachInterval(2))=true;
            set(currentValueH,'string','');
            set(currentXH,'string','');
            [guitempdata.frapCurve,guitempdata.frapCurvePlotH,guitempdata.withinRangeFrapPoints,guitempdata.withinRangePreBleachPoints,guitempdata.lh]=redrawCurveAndLines(guitempdata.frapCurve,curveSource,guitempdata.bl,guitempdata.bg,guitempdata.tot,guitempdata.recoveryInterval,guitempdata.prebleachInterval,whichButton,guitempdata.manuallySelectedPoints,guitempdata.frapCurvePlotH,guitempdata.lh,ah,handleOfMain,initUpperLowerH);
            [initialGuesses,bounds]=generateGuesses(guitempdata.fitType,guitempdata.frapCurve,guitempdata.prebleachInterval,guitempdata.recoveryInterval,guitempdata.manuallySelectedPoints);
            guitempdata.i0Guess=initialGuesses(1);
            guitempdata=updateInitialGuessesAndBounds(guitempdata,initialGuesses,bounds,initUpperLowerH);
        else % move
            yLim=get(ah,'ylim');
            if ishandle(guitempdata.lh(guitempdata.whichLineClicked))
                delete(guitempdata.lh(guitempdata.whichLineClicked));
            end
            guitempdata.lh(guitempdata.whichLineClicked)=line([xOfLine xOfLine],[yLim(1) yLim(2)],'parent',ah,'userdata',guitempdata.whichLineClicked,'color',colorOfLine);
        end
        guidata(handleOfMain,guitempdata);
        drawnow;
    end
end

function [frapCurve,frapCurvePlotH,withinRangeFrapPoints,withinRangePreBleachPoints,lh]=redrawCurveAndLines(frapCurve,curveSource,bl,bg,tot,recoveryInterval,prebleachInterval,whichButton,manuallySelectedPoints,frapCurvePlotH,lh,ah,handleOfMain,initUpperLowerH)
if curveSource==1
    frapCurve=normalizeFrapData(bl,bg,tot,recoveryInterval,prebleachInterval,whichButton,manuallySelectedPoints);
end
delete(frapCurvePlotH);
delete(lh);
set(ah(1),'ylimmode','auto');
frapCurvePlotH=gobjects(numel(frapCurve),1);
withinRangeFrapPoints=false(numel(frapCurve),1);
withinRangePreBleachPoints=false(numel(frapCurve),1);
withinRangeFrapPoints(recoveryInterval(1):recoveryInterval(2))=true;
withinRangePreBleachPoints(prebleachInterval(1):prebleachInterval(2))=true;
for i=1:numel(frapCurve)
    frapCurvePlotH(i)=plot(i,frapCurve(i),'o','parent',ah(1));
    if (i>=prebleachInterval(1) && i<=prebleachInterval(2)) || (i>=recoveryInterval(1) && i<=recoveryInterval(2))
        set(frapCurvePlotH(i),'buttondownfcn',{@symbol_callback,i,ah,handleOfMain,curveSource,whichButton,initUpperLowerH});
    end
    setMarkerFaceEdgeColor(manuallySelectedPoints(i),withinRangeFrapPoints(i),withinRangePreBleachPoints(i),frapCurvePlotH(i));
end
drawnow;
set(ah(1),'ylimmode','manual');
yLim=get(ah(1),'ylim');
lh(1)=line([prebleachInterval(1) prebleachInterval(1)],[yLim(1) yLim(2)],'parent',ah(1),'color','r','userdata',1);
lh(2)=line([prebleachInterval(2) prebleachInterval(2)],[yLim(1) yLim(2)],'parent',ah(1),'color','r','userdata',2);
lh(3)=line([recoveryInterval(1) recoveryInterval(1)],[yLim(1) yLim(2)],'parent',ah(1),'color','b','userdata',3);
lh(4)=line([recoveryInterval(2) recoveryInterval(2)],[yLim(1) yLim(2)],'parent',ah(1),'color','b','userdata',4);
set(lh,'buttondownfcn',{@lineMove_callback,handleOfMain});

function lineMove_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
guitempdata.whichLineClicked=get(src,'userdata');
guidata(handleOfMain,guitempdata);

function frapCurve=normalizeFrapData(bl,bg,tot,recoveryInterval,prebleachInterval,whichButton,manuallySelectedPoints)
switch whichButton
    case 1 % no normalization
        frapCurve=bl;
    case 2 % bg subtraction
        frapCurve=bl-bg;
    case 3 % normalize to prebleach
        bl0=bl(prebleachInterval(1):prebleachInterval(2));
        bl0=mean(bl0(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
        bg0=bg(prebleachInterval(1):prebleachInterval(2));
        bg0=mean(bg0(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
        frapCurve=(bl-bg)/(bl0-bg0);
    case 4 % double normalization
        frapCurve=doubleNormalization(bl,bg,tot,prebleachInterval,manuallySelectedPoints);
    case 5 % triple normalization
        dn=doubleNormalization(bl,bg,tot,prebleachInterval,manuallySelectedPoints);
        frapCurve=1-(1-dn)/(1-dn(recoveryInterval(1)));
end

function frapCurve=doubleNormalization(bl,bg,tot,prebleachInterval,manuallySelectedPoints)
bl0=bl(prebleachInterval(1):prebleachInterval(2));
bl0=mean(bl0(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
bg0=bg(prebleachInterval(1):prebleachInterval(2));
bg0=mean(bg0(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
tot0=tot(prebleachInterval(1):prebleachInterval(2));
tot0=mean(tot0(manuallySelectedPoints(prebleachInterval(1):prebleachInterval(2))));
frapCurve=(bl-bg)/(bl0-bg0).*(tot0-bg0)./(tot-bg);

function reenableControls(src,evt,pushBH,editableH,enableStatus,exportButtonH,mainButtonHs,resultOfFitH,whichMethod,handleOfMain,curveSource,varName,fromWhere)
if strcmp(fromWhere,'figure')
    delete(src);
else
    delete(get(src,'parent'));
end
if ishandle(pushBH)
    set(handleOfMain,'closerequestfcn','closereq');
    for i=1:numel(editableH)
        set(editableH(i),'enable',enableStatus{i});
    end
    guitempdata=guidata(handleOfMain);
    if guitempdata.fitSuccess
        set(exportButtonH,'enable','on');
        switch whichMethod
            case 1
                normMethodText='no normalization';
            case 2
                normMethodText='background subtraction';
            case 3
                normMethodText='normalization to prebleach';
            case 4
                normMethodText='double normalization';
            case 5
                normMethodText='triple normalization';
        end
        if curveSource==1 % images
            sourceText=['images (',varName,')'];
        else
            sourceText=['data points (',varName,')'];
        end
        reportText=['RESULT OF FIT',newline,'Source of data: ',sourceText,newline];
        coeffNamesToShow=guitempdata.allPotencialCoefficients;
        coeffNamesToShow{strcmp(coeffNamesToShow,'a')}='Extent of bleaching';
        for i=1:numel(guitempdata.fittedParameters)
            if guitempdata.constantInCurrentModel(i)
                reportText=[reportText,coeffNamesToShow{i},': ',num2str(guitempdata.fittedParameters(i)),' (constant parameter)',newline];
            else
                reportText=[reportText,coeffNamesToShow{i},': ',num2str(guitempdata.fittedParameters(i)),' (',num2str(guitempdata.confIntervals(i,1)),'-',num2str(guitempdata.confIntervals(i,2)),')',newline];
            end
        end
        reportText=[reportText,'Io: ',num2str(guitempdata.i0),newline,...
            'Normalization method: ',normMethodText,newline];
        disp(reportText);
    else % if fitting has NOT been performed
        set(resultOfFitH(1:5,:),'string','');
        set(resultOfFitH(6,1),'string','');
        reportText=['RESULT OF FIT',newline,'No fitting has been performed.'];
        disp(reportText);
    end
    set(mainButtonHs,'enable','on');
    figure(handleOfMain);
end

function exportData(dataToWrite,identifiers,resp,tableYes,fromWhere,handleOfMain)
guitempdata=guidata(handleOfMain);
switch resp
    case 1 % Export data to a cell or table variable
        onceMore=1;
        while onceMore==1
            varName=inputdlg('Name of variable','Variable name');
            if isempty(varName)
                onceMore=0;
            elseif isempty(varName{1})
                errordlg('Variable name is empty.','Oops','modal');
                uiwait;
            elseif ~isvarname(varName{1})
                errordlg('Not a valid variable name.','Oops','modal');
                uiwait;
            else
                varName=varName{1};
                try
                    dummy=evalin('base',varName);
                    existVar=1;
                catch
                    existVar=0;
                end
                if existVar==1
                    resp2=questdlg('Variable already exists. Shall I overwrite it?','Overwrite','Yes','No','Yes');
                else
                    resp2='Yes';
                end
                if strcmp(resp2,'Yes')
                    switch fromWhere
                        case 'main'
                            if tableYes
                                variables=identifiers';
                                values=dataToWrite';
                                thingToWrite=table(variables,values);
                            else
                                thingToWrite=cell(11,2);
                                thingToWrite(:,1)=identifiers';
                                thingToWrite(:,2)=num2cell(dataToWrite);
                            end
                        case 'plot'
                            if tableYes
                                switch size(dataToWrite,2)
                                    case 2
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),'variablenames',identifiers);
                                    case 3
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),dataToWrite(:,3),'variablenames',identifiers);
                                    case 4
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),dataToWrite(:,3),dataToWrite(:,4),'variablenames',identifiers);
                                    case 5
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),dataToWrite(:,3),dataToWrite(:,4),dataToWrite(:,5),'variablenames',identifiers);
                                    case 6
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),dataToWrite(:,3),dataToWrite(:,4),dataToWrite(:,5),dataToWrite(:,6),'variablenames',identifiers);
                                    case 7
                                        thingToWrite=table(dataToWrite(:,1),dataToWrite(:,2),dataToWrite(:,3),dataToWrite(:,4),dataToWrite(:,5),dataToWrite(:,6),dataToWrite(:,7),'variablenames',identifiers);
                                end
                            else
                                thingToWrite=dataToWrite;
                            end
                    end
                    assignin('base',varName,thingToWrite);
                    msgbox('Variable saved','I''m done','modal');
                    uiwait;
                    onceMore=0;
                end
            end
        end
    case 2 % Export data to a TXT file
        defPath=guitempdata.resultfilepath;
        [fileName,newPath]=uiputfile('*.txt','Save variable as',defPath);
        if fileName~=0
            fileH=fopen([newPath,fileName],'w');
            switch fromWhere
                case 'main'
                    for i=1:numel(dataToWrite)
                        fprintf(fileH,'%s\t%f',identifiers{i},dataToWrite(i));
                        if i~=numel(dataToWrite)
                            fprintf(fileH,'\r\n');
                        end
                    end
                case 'plot'
                    switch size(dataToWrite,2)
                        case 2
                            fprintf(fileH,'%s\t%s\r\n',identifiers{1},identifiers{2});
                        case 3
                            fprintf(fileH,'%s\t%s\t%s\r\n',identifiers{1},identifiers{2},identifiers{3});
                        case 4
                            fprintf(fileH,'%s\t%s\t%s\t%s\r\n',identifiers{1},identifiers{2},identifiers{3},identifiers{4});
                        case 5
                            fprintf(fileH,'%s\t%s\t%s\t%s\t%s\r\n',identifiers{1},identifiers{2},identifiers{3},identifiers{4},identifiers{5});
                        case 6
                            fprintf(fileH,'%s\t%s\t%s\t%s\t%s\t%s\r\n',identifiers{1},identifiers{2},identifiers{3},identifiers{4},identifiers{5},identifiers{6});
                        case 7
                            fprintf(fileH,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',identifiers{1},identifiers{2},identifiers{3},identifiers{4},identifiers{5},identifiers{6},identifiers{7});
                    end
                    for i=1:size(dataToWrite,1)
                        switch size(dataToWrite,2)
                            case 2
                                fprintf(fileH,'%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2));
                            case 3
                                fprintf(fileH,'%f\t%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2),dataToWrite(i,3));
                            case 4
                                fprintf(fileH,'%f\t%f\t%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2),dataToWrite(i,3),dataToWrite(i,4));
                            case 5
                                fprintf(fileH,'%f\t%f\t%f\t%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2),dataToWrite(i,3),dataToWrite(i,4),dataToWrite(i,5));
                            case 6
                                fprintf(fileH,'%f\t%f\t%f\t%f\t%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2),dataToWrite(i,3),dataToWrite(i,4),dataToWrite(i,5),dataToWrite(i,6));
                            case 7
                                fprintf(fileH,'%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n',dataToWrite(i,1),dataToWrite(i,2),dataToWrite(i,3),dataToWrite(i,4),dataToWrite(i,5),dataToWrite(i,6),dataToWrite(i,7));
                        end
                    end
            end
            fclose(fileH);
            guitempdata.resultfilepath=newPath;
            assignin('base','resultfilepath_frapfit',newPath);
            msgbox('File saved','I''m done','modal');
            uiwait;
        end
    case 3 % export data to a MAT file
        defPath=guitempdata.resultfilepath;
        [fileName,newPath]=uiputfile('*.mat','Save variable as',defPath);
        if fileName~=0
            switch fromWhere
                case 'main'
                    switch guitempdata.fitTypeCompleted
                        case 1 % 1-exp
                            bleaching_extent=dataToWrite(1);
                            tau=dataToWrite(2);
                            immobileFr=dataToWrite(3);
                            i0=dataToWrite(4);
                            bleaching_extent_CI1=dataToWrite(5);
                            bleaching_extent_CI2=dataToWrite(6);
                            tau_CI1=dataToWrite(7);
                            tau_CI2=dataToWrite(8);
                            immobileFr_CI1=dataToWrite(9);
                            immobileFr_CI2=dataToWrite(10);
                            save([newPath,fileName],'bleaching_extent','tau','immobileFr','i0','bleaching_extent_CI1','bleaching_extent_CI2','tau_CI1','tau_CI2','immobileFr_CI1','immobileFr_CI2');
                        case 2 % 2-exp
                            bleaching_extent=dataToWrite(1);
                            tau1=dataToWrite(2);
                            tau2=dataToWrite(3);
                            f1=dataToWrite(4);
                            immobileFr=dataToWrite(5);
                            i0=dataToWrite(6);
                            bleaching_extent_CI1=dataToWrite(7);
                            bleaching_extent_CI2=dataToWrite(8);
                            tau1_CI1=dataToWrite(9);
                            tau1_CI2=dataToWrite(10);
                            tau2_CI1=dataToWrite(11);
                            tau2_CI2=dataToWrite(12);
                            f1_CI1=dataToWrite(13);
                            f1_CI2=dataToWrite(14);
                            immobileFr_CI1=dataToWrite(15);
                            immobileFr_CI2=dataToWrite(16);
                            save([newPath,fileName],'bleaching_extent','tau1','tau2','f1','immobileFr','i0','bleaching_extent_CI1','bleaching_extent_CI2','tau1_CI1','tau1_CI2','tau2_CI1','tau2_CI2','f1_CI1','f1_CI2','immobileFr_CI1','immobileFr_CI2');
                    end
                case 'plot'
                    if isempty(guitempdata.fittedCurve)
                        switch size(dataToWrite,2)
                            case 2
                                frapCurve=dataToWrite(:,1);
                                selectedPoints=dataToWrite(:,2);
                                save([newPath,fileName],'frapCurve','selectedPoints');
                            case 3
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                selectedPoints=dataToWrite(:,3);
                                save([newPath,fileName],'frapCurve','bleachCurve','selectedPoints');
                            case 4
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                bgCurve=dataToWrite(:,3);
                                selectedPoints=dataToWrite(:,4);
                                save([newPath,fileName],'frapCurve','bleachCurve','bgCurve','selectedPoints');
                            case 5
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                unbleachedCurve=dataToWrite(:,3);
                                bgCurve=dataToWrite(:,4);
                                selectedPoints=dataToWrite(:,5);
                                save([newPath,fileName],'frapCurve','bleachCurve','unbleachedCurve','bgCurve','selectedPoints');
                        end
                    else
                        switch size(dataToWrite,2)
                            case 4
                                frapCurve=dataToWrite(:,1);
                                fittedCurve=dataToWrite(:,2);
                                residualCurve=dataToWrite(:,3);
                                selectedPoints=dataToWrite(:,4);
                                save([newPath,fileName],'frapCurve','fittedCurve','residualCurve','selectedPoints');
                            case 5
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                fittedCurve=dataToWrite(:,3);
                                residualCurve=dataToWrite(:,4);
                                selectedPoints=dataToWrite(:,5);
                                save([newPath,fileName],'frapCurve','bleachCurve','fittedCurve','residualCurve','selectedPoints');
                            case 6
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                bgCurve=dataToWrite(:,3);
                                fittedCurve=dataToWrite(:,4);
                                residualCurve=dataToWrite(:,5);
                                selectedPoints=dataToWrite(:,6);
                                save([newPath,fileName],'frapCurve','bleachCurve','bgCurve','fittedCurve','residualCurve','selectedPoints');
                            case 7
                                frapCurve=dataToWrite(:,1);
                                bleachCurve=dataToWrite(:,2);
                                unbleachedCurve=dataToWrite(:,3);
                                bgCurve=dataToWrite(:,4);
                                fittedCurve=dataToWrite(:,5);
                                residualCurve=dataToWrite(:,6);
                                selectedPoints=dataToWrite(:,7);
                                save([newPath,fileName],'frapCurve','bleachCurve','unbleachedCurve','bgCurve','fittedCurve','residualCurve','selectedPoints');
                        end
                    end
            end
            guitempdata.resultfilepath=newPath;
            assignin('base','resultfilepath_frapfit',newPath);
            msgbox('File saved','I''m done','modal');
            uiwait;
        end
end
guidata(handleOfMain,guitempdata);

function export_callback(src,evt,fromWhere,whichButton,curveSource,handleOfMain)
if ishandle(handleOfMain)
    % decide if table type is available
    tableYes=true;
    try
        col1=[1 2]';
        table(col1,'rownames',{'1st row','2nd row'});
    catch
        tableYes=false;
    end
    switch fromWhere
        case 'main'
            dataType='results';
        case 'plot'
            dataType='curves';
    end
    if tableYes
        response=dialogWithManyButtons('What to do?','Options',{['Export ',dataType,' to a table variable'],['Export ',dataType,' to a TXT file'],['Export ',dataType,' to a MAT file'],'Nothing'},[170 25],handleOfMain);
    else
        response=dialogWithManyButtons('What to do?','Options',{['Export ',dataType,' to a cell variable'],['Export ',dataType,' to a TXT file'],['Export ',dataType,' to a MAT file'],'Nothing'},[170 25],handleOfMain);
    end
    if ismember(response,[1 2 3])
        guitempdata=guidata(handleOfMain);
        switch fromWhere
            case 'main'
                dataToExport=[guitempdata.fittedParameters', guitempdata.i0, reshape(permute(guitempdata.confIntervals,[2,1]),[1 numel(guitempdata.confIntervals)])];
                identifiers=cell(1,3*numel(guitempdata.fittedParameters)+1);
                identifiers(1:numel(guitempdata.fittedParameters)+1)=[guitempdata.allPotencialCoefficients,'I0'];
                for i=1:numel(guitempdata.fittedParameters)
                    identifiers{numel(guitempdata.fittedParameters)+1+(i-1)*2+1}=[cell2mat(guitempdata.allPotencialCoefficients(i)),' CI1'];
                    identifiers{numel(guitempdata.fittedParameters)+1+i*2}=[cell2mat(guitempdata.allPotencialCoefficients(i)),' CI2'];
                end
                identifiers{strcmp(identifiers,'a')}='Extent of bleaching';
                identifiers{strcmp(identifiers,'a CI1')}='Extent of bleaching CI1';
                identifiers{strcmp(identifiers,'a CI2')}='Extent of bleaching CI2';
                exportData(dataToExport,identifiers,response,tableYes,fromWhere,handleOfMain);
            case 'plot'
                if isempty(guitempdata.fittedCurve)
                    if curveSource==1 % images
                        switch whichButton
                            case 1
                                dataToExport=[guitempdata.frapCurve,guitempdata.bl,generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval)];
                                identifiers={'FRAP','Bleach','Selected'};
                            case {2,3}
                                dataToExport=[guitempdata.frapCurve,guitempdata.bl,guitempdata.bg,generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval)];
                                identifiers={'FRAP','Bleach','Bg','Selected'};
                            case {4,5}
                                dataToExport=[guitempdata.frapCurve,guitempdata.bl,guitempdata.tot,guitempdata.bg,generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval)];
                                identifiers={'FRAP','Bleach','Unbleached','Bg','Selected'};
                        end
                    else % data points
                        dataToExport=[guitempdata.frapCurve,generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval)];
                        identifiers={'FRAP','Selected'};
                    end
                else
                    if curveSource==1 % images
                        switch whichButton
                            case 1
                                dataToExport=zeros(numel(guitempdata.frapCurve),5)*nan;
                                dataToExport(:,1:2)=[guitempdata.frapCurve,guitempdata.bl];
                                dataToExport(guitempdata.recoveryInterval(1):end,3:4)=[guitempdata.fittedCurve,guitempdata.residualCurve];
                                dataToExport(:,5)=generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval);
                                identifiers={'FRAP','Bleach','Fit','Residual','Selected'};
                            case {2,3}
                                dataToExport=zeros(numel(guitempdata.frapCurve),6)*nan;
                                dataToExport(:,1:3)=[guitempdata.frapCurve,guitempdata.bl,guitempdata.bg];
                                dataToExport(guitempdata.recoveryInterval(1):end,4:5)=[guitempdata.fittedCurve,guitempdata.residualCurve];
                                dataToExport(:,6)=generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval);
                                identifiers={'FRAP','Bleach','Bg','Fit','Residual','Selected'};
                            case {4,5}
                                dataToExport=zeros(numel(guitempdata.frapCurve),7)*nan;
                                dataToExport(:,1:4)=[guitempdata.frapCurve,guitempdata.bl,guitempdata.tot,guitempdata.bg];
                                dataToExport(guitempdata.recoveryInterval(1):end,5:6)=[guitempdata.fittedCurve,guitempdata.residualCurve];
                                dataToExport(:,7)=generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval);
                                identifiers={'FRAP','Bleach','Unbleached','Bg','Fit','Residual','Selected'};
                        end
                    else % data points
                        dataToExport=zeros(numel(guitempdata.frapCurve),4)*nan;
                        dataToExport(:,1)=guitempdata.frapCurve;
                        dataToExport(guitempdata.recoveryInterval(1):end,2:3)=[guitempdata.fittedCurve,guitempdata.residualCurve];
                        dataToExport(:,4)=generateSelectedPointsColumn(guitempdata.manuallySelectedPoints,guitempdata.prebleachInterval,guitempdata.recoveryInterval);
                        identifiers={'FRAP','Fit','Residual','Selected'};
                    end
                end
                exportData(dataToExport,identifiers,response,tableYes,fromWhere,handleOfMain);
        end
    end
end

function selectedArray=generateSelectedPointsColumn(manuallySelectedPoints,prebleachInterval,recoveryInterval)
selectedArray=false(numel(manuallySelectedPoints),1);
selectedArray(prebleachInterval(1):prebleachInterval(2))=true;
selectedArray(recoveryInterval(1):recoveryInterval(2))=true;
selectedArray=selectedArray & manuallySelectedPoints;

function resp=dialogWithManyButtons(question,title,buttonstrings,buttonsize,src)
srcPos=get(src,'position');
scrsz=get(0,'ScreenSize');
numOfButtons=numel(buttonstrings);
dlgsz=[buttonsize(1)+20,numOfButtons*buttonsize(2)+(numOfButtons-1)*10+50];
dlgPos=[srcPos(1)+srcPos(3)/2-dlgsz(1)/2 srcPos(2)+srcPos(4)/2-dlgsz(2)/2 dlgsz];
if dlgPos(1)+dlgPos(3)>scrsz(3)
    dlgPos(1)=dlgPos(1)-(dlgPos(1)+dlgPos(3)-scrsz(3));
end
dh=dialog('Name',title,'Position',dlgPos,'windowstyle','modal','toolbar','none','menubar','none','units','pixels');
pushH=zeros(numOfButtons,1);
eh=0;
for i=1:numOfButtons
    pushH(i)=uicontrol('parent',dh,'style','pushbutton','units','pixels','position',[10 dlgsz(2)-50-(i-1)*buttonsize(2)-(i>1)*(i-1)*10 buttonsize],'fontsize',8,'string',buttonstrings{i},'userdata',i);
end
for i=1:numOfButtons
    set(pushH(i),'callback',{@mypushbutton_callback,buttonstrings,dh,eh});
end
uicontrol('parent',dh,'style','text','units','pixels','position',[10 dlgsz(2)-20 100 15],'string',question,'fontsize',8);
set(dh,'CloseRequestFcn',{@mypushbutton_callback,buttonstrings,dh,eh});
uiwait(dh);
resp=guidata(dh);
delete(dh);

function mypushbutton_callback(src,evt,buttonstrings,dh,eh)
if src==dh
    guidata(dh,'-1');
else
    guidata(dh,get(src,'userdata'));
end
uiresume(dh);

function drawOnH_callback(src,evt,editHs)
whichButton=get(src,'userdata');
set(editHs(1:numel(editHs)~=whichButton),'string',get(src,'string'));

function errorFound=checkRoiSizes(guitempdata,sizeOfBgImage)
% Since guitempdata mask images are dipimages, and 'sizeOfBgImage'
% corresponds to the size of a Matlab array, the X and Y dimesions in
% 'sizeOfBgImage' are swapped.
sizeOfBgImage=[sizeOfBgImage(2) sizeOfBgImage(1) sizeOfBgImage(3:end)];
errorFound=false;
threeRois={guitempdata.bleachRoi,guitempdata.membraneRoi,guitempdata.bgRoi};
reference=find(arrayfun(@(x) ~isempty(x{:}),threeRois),1);
others=1:3;
others=others(1:3~=reference);
if sum(size(threeRois{reference},1:2)==sizeOfBgImage(1:2))~=2
    errorFound=1;
end
if sum(size(threeRois{reference},1:2)==size(threeRois{others(1)},1:2))~=2 && ~isempty(threeRois{others(1)})
    errorFound=1;
end
if sum(size(threeRois{reference},1:2)==size(threeRois{others(2)},1:2))~=2 && ~isempty(threeRois{others(2)})
    errorFound=1;
end
if (size(guitempdata.bleachRoi,3)>1 || numel(sizeOfBgImage)>2) && size(guitempdata.bleachRoi,3)~=sizeOfBgImage(3) && ~isempty(guitempdata.bleachRoi) && size(guitempdata.bleachRoi,3)>1
    errorFound=1;
end
if (size(guitempdata.membraneRoi,3)>1 || numel(sizeOfBgImage)>2) && size(guitempdata.membraneRoi,3)~=sizeOfBgImage(3) && ~isempty(guitempdata.membraneRoi)  && size(guitempdata.membraneRoi,3)>1
    errorFound=1;
end
if (size(guitempdata.bgRoi,3)>1 || numel(sizeOfBgImage)>2) && size(guitempdata.bgRoi,3)~=sizeOfBgImage(3) && ~isempty(guitempdata.bgRoi)  && size(guitempdata.bgRoi,3)>1
    errorFound=1;
end
if errorFound
    eh=errordlg(['Size mismatch. Size of image: ',num2str(sizeOfBgImage),newline,'Size of bleaching ROI: ',num2str(size(guitempdata.bleachRoi)),newline,...
        'Size of unbleached ROI: ',num2str(size(guitempdata.membraneRoi)),newline,'Size of background ROI: ',num2str(size(guitempdata.bgRoi))],'Oops');
    uiwait(eh);
end

function showAllRois_callback(src,evt,drawonHoverlay,slider2Handle,sliceText2Handle,sliderMinText2Handle,sliderMaxText2Handle,emptyOrFilled,checkBoxOverlayH,setTransparencyEH,lth,framerateEH,movieButtonH,handleOfMain)
guitempdata=guidata(handleOfMain);
if strcmp(get(src,'string'),'Show current ROIs') % show ROIs
    drawonName=get(drawonHoverlay,'string');
    if isempty(drawonName)
        errordlg('Name of image to draw on is empty','Oops','modal');
        return;
    end
    try
        overlayImage3D=double(evalin('base',drawonName));
    catch
        errordlg('Error reading image to draw on.','Oops','modal');
        return;
    end
    guitempdata.currentSlice=1;
    overlayImage=squeeze(overlayImage3D(:,:,guitempdata.currentSlice));
    if isempty(guitempdata.bleachRoi) && isempty(guitempdata.membraneRoi) && isempty(guitempdata.bgRoi)
        errordlg('All three ROIs are empty.','Oops','modal');
        return;
    end
    errorFound=checkRoiSizes(guitempdata,size(overlayImage3D)); % guitempdata mask images are dipimages, overlayImage3D is double. The size of the latter will be inverted by 'checkRoiSizes'
    if errorFound
        return;
    end
    messageCounter=0;
    if isempty(guitempdata.bleachRoi)
        messageCounter=messageCounter+1;
        messageText{messageCounter}='bl.';
    end
    if isempty(guitempdata.membraneRoi)
        messageCounter=messageCounter+1;
        messageText{messageCounter}='unbl.';
    end
    if isempty(guitempdata.bgRoi)
        messageCounter=messageCounter+1;
        messageText{messageCounter}='bg';
    end
    if messageCounter>0
        if messageCounter==1
            finalMessageText='Empty ROI: ';
        else
            finalMessageText='Empty ROIs: ';
        end
        for i=1:messageCounter
            if i==messageCounter
                finalMessageText=[finalMessageText,messageText{i}];
            else
                finalMessageText=[finalMessageText,messageText{i},','];
            end 
        end
        guidata(handleOfMain,guitempdata);
        displayTimedMessage(finalMessageText,lth,3,handleOfMain);
        guitempdata=guidata(handleOfMain);
    end
    whichButton=find(cellfun(@(x) x,get(emptyOrFilled,'value')));
    guitempdata.overlayfigureH=figure;
    imshow(overlayImage,[prctile(overlayImage(:),1) prctile(overlayImage(:),99)]);
    guitempdata.overlayaxisH=gca;
    set(guitempdata.overlayfigureH,'closerequestfcn',{@simulateFinishPress3_callback,src,drawonHoverlay,slider2Handle,emptyOrFilled,framerateEH,movieButtonH,setTransparencyEH,handleOfMain});
    hold on;
    guitempdata.allRoisOnOverlayH=drawAllRois(guitempdata.bleachRoiStruct,guitempdata.membraneRoiStruct,guitempdata.bgRoiStruct,guitempdata.overlayaxisH,guitempdata.bleachRoi,guitempdata.membraneRoi,guitempdata.bgRoi,...
        guitempdata.bleachRoiImageType,guitempdata.membraneRoiImageType,guitempdata.bgRoiImageType,whichButton,guitempdata.facealpha,1);
    set(src,'string','Stop viewing overlay image');
    set(drawonHoverlay,'enable','off');
    set(emptyOrFilled,'enable','off');
    set(setTransparencyEH,'enable','off');
    set(guitempdata.mainbuttonhandles,'enable','off');
    set(framerateEH,'enable','off');
    set(movieButtonH,'enable','off');
    zSize=size(overlayImage3D,3);
    guitempdata.listenerForOverlay=addlistener(slider2Handle,'Value','PostSet',@(obj,evt) slider2_callback(obj,evt,slider2Handle,sliceText2Handle,emptyOrFilled,overlayImage3D,handleOfMain));
    guidata(handleOfMain,guitempdata); % updating guidata must be done here because the slider callback may be called in the if-then section below, and the slider callback uses the guidata
    % DO NOT MODIFY guitempdata BELOW
    if zSize>1
        set(slider2Handle,'enable','on');
        set(sliceText2Handle,'string','1');
        set(sliderMinText2Handle,'string','1');
        set(sliderMaxText2Handle,'string',num2str(zSize));
        set(slider2Handle,'max',zSize);
        set(slider2Handle,'value',1);
        bigStep=10/(zSize-1);
        if bigStep>=1
            bigStep=1/(zSize-1);
        end
        set(slider2Handle,'sliderstep',[1/(zSize-1) bigStep]);
    end
else % stop viewing overlay image (delete overlay image)
    if ishandle(guitempdata.overlayfigureH)
        if get(checkBoxOverlayH,'value')==1
            delete(guitempdata.overlayfigureH);
        end
    end
    delete(guitempdata.listenerForOverlay);
    guitempdata.overlayfigureH=0;
    set(src,'string','Show current ROIs');
    set(drawonHoverlay,'enable','on');
    set(slider2Handle,'enable','off');
    set(emptyOrFilled,'enable','on');
    set(setTransparencyEH,'enable','on');
    set(guitempdata.mainbuttonhandles,'enable','on');
    set(framerateEH,'enable','on');
    set(movieButtonH,'enable','on');
    if strcmp(class(guitempdata.listenerForOverlay),'event.proplistener')
        delete(guitempdata.listenerForOverlay);
    end
    guitempdata.listenerForOverlay=0;
    guidata(handleOfMain,guitempdata);
end

function simulateFinishPress3_callback(src,evt,buttonH,drawonHoverlay,slider2Handle,emptyOrFilled,framerateEH,movieButtonH,setTransparencyEH,handleOfMain)
delete(src);
if ishandle(handleOfMain)
    guitempdata=guidata(handleOfMain);
else
    return;
end
delete(guitempdata.listenerForOverlay);
guitempdata.overlayfigureH=0;
set(buttonH,'string','Show current ROIs');
set(drawonHoverlay,'enable','on');
set(slider2Handle,'enable','off');
set(emptyOrFilled,'enable','on');
set(setTransparencyEH,'enable','on');
set(guitempdata.mainbuttonhandles,'enable','on');
set(framerateEH,'enable','on');
set(movieButtonH,'enable','on');
guidata(handleOfMain,guitempdata);

function viewImages_callback(src,evt,inputSmoothEditHandle,sliderSmoothHandle,sliceTextHandle,sliderMinTextHandle,sliderMaxTextHandle,gaussSmoothEditHandle,exportH,checkBoxExportH,handleOfMain)
guitempdata=guidata(handleOfMain);
buttonState=get(src,'userdata');
if buttonState==0 % view images
    inputName=get(inputSmoothEditHandle,'string');
    if isempty(inputName)
        errordlg('Source image name is empty.','Oops','modal');
        return;
    end
    try
        inputImage=evalin('base',inputName);
    catch
        errordlg('Error reading source image.','Oops','modal');
        return;
    end
    gaussSD=str2double(get(gaussSmoothEditHandle,'string'));
    if isnan(gaussSD)
        gaussSD=0;
    end
    guitempdata.viewedImage=inputImage;
    inputImage=gaussf(inputImage,gaussSD);
    guitempdata.displayWindowHandle=dipshow(inputImage,'lin');
    guitempdata.listenerForSmoothing=addlistener(sliderSmoothHandle,'Value','PostSet',@(obj,evt) sliderSmooth_callback(obj,evt,sliderSmoothHandle,sliceTextHandle,handleOfMain));
    guidata(handleOfMain,guitempdata); % updating guidata must be done here because the slider callback may be called in the section below, and the slider callback uses the guidata
    % DO NOT MODIFY guitempdata BELOW
    dipmapping(guitempdata.displayWindowHandle,'global');
    set(guitempdata.displayWindowHandle,'closerequestfcn',{@simulateFinishPress2_callback,src,sliderSmoothHandle,inputSmoothEditHandle,exportH,handleOfMain});
    set(sliceTextHandle,'string','1');
    set(sliderMinTextHandle,'string','1');
    zSize=size(inputImage,3);
    if zSize>1
        set(sliderMaxTextHandle,'string',num2str(zSize));
        set(sliderSmoothHandle,'max',zSize);
        set(sliderSmoothHandle,'value',1);
        bigStep=10/(zSize-1);
        if bigStep>=1
            bigStep=1/(zSize-1);
        end
        set(sliderSmoothHandle,'sliderstep',[1/(zSize-1) bigStep]);
        set(sliderSmoothHandle,'enable','on');
    end
    set(exportH,'enable','off');
    set(src,'string','Stop viewing');
    set(src,'userdata',1);
    set(inputSmoothEditHandle,'enable','off');
else % stop viewing images
    set(src,'string','Start viewing');
    set(src,'userdata',0);
    set(sliderSmoothHandle,'enable','off');
    set(inputSmoothEditHandle,'enable','on');
    set(exportH,'enable','on');
    if ishandle(guitempdata.displayWindowHandle) && guitempdata.displayWindowHandle~=0
        if get(checkBoxExportH,'value')==1
            delete(guitempdata.displayWindowHandle);
        end
    end
    guitempdata.displayWindowHandle=0;
    guitempdata.viewedImage=[];
    if strcmp(class(guitempdata.listenerForSmoothing),'event.proplistener')
        delete(guitempdata.listenerForSmoothing);
    end
    guitempdata.listenerForSmoothing=0;
    guidata(handleOfMain,guitempdata);
end

function slider2_callback(obj,evt,src,sliceTextHandle,emptyOrFilled,overlayImage3D,handleOfMain)
guitempdata=guidata(handleOfMain);
currentSlice=round(get(src,'value'));
figure(guitempdata.overlayfigureH);
overlayImage=squeeze(overlayImage3D(:,:,currentSlice));
imshow(overlayImage,[prctile(overlayImage(:),1) prctile(overlayImage(:),99)])
set(sliceTextHandle,'string',num2str(currentSlice));
delete(guitempdata.allRoisOnOverlayH);
whichButton=find(cellfun(@(x) x,get(emptyOrFilled,'value')));
guitempdata.allRoisOnOverlayH=drawAllRois(guitempdata.bleachRoiStruct,guitempdata.membraneRoiStruct,guitempdata.bgRoiStruct,guitempdata.overlayaxisH,guitempdata.bleachRoi,guitempdata.membraneRoi,guitempdata.bgRoi,...
        guitempdata.bleachRoiImageType,guitempdata.membraneRoiImageType,guitempdata.bgRoiImageType,whichButton,guitempdata.facealpha,currentSlice);
guidata(handleOfMain,guitempdata);
guitempdata.currentSlice=currentSlice;
guidata(handleOfMain,guitempdata);

function shownRoiType_callback(src,evt,emptyOrFilled,setTransparencyEH,handleOfMain)
whichButton=find(cellfun(@(x) x,get(emptyOrFilled,'value')));
guitempdata=guidata(handleOfMain);
if whichButton==1 % filled
    set(guitempdata.legendH,'facealpha',guitempdata.facealpha);
    set(setTransparencyEH,'enable','on');
else % empty
    set(guitempdata.legendH,'facealpha',0);
    set(setTransparencyEH,'enable','off');
end

function Update_callback(src,evt)
msgbox(['I',char(39),'m an M-file. I can',char(39),'t be updated.'],'Oops','warn','modal');

function roiH=drawAllRoisSubroutine(colorLetter,RoiStruct,RoiImageType,axisH,bleachRoi,membraneRoi,bgRoi,faceAlpha,currentSlice,whichButton,roiType)
k=0;
switch RoiStruct.roiType
    case 'Image'
        boundaries=RoiStruct.roiData.Boundaries;
        if RoiImageType==2 % 3D
            boundaries=boundaries{currentSlice};
        end
        if ~iscell(boundaries)
            tempCoord=boundaries;
            boundaries=cell(1,1);
            boundaries{1}=tempCoord;
        end
        for i=1:numel(boundaries)
            k=k+1;
            roiH(k)=line(boundaries{i}(:,1),boundaries{i}(:,2),'color',colorLetter,'parent',axisH);
        end
        switch roiType
            case 'bleached'
                if RoiImageType==2 % 3D
                    bleachRoi=squeeze(bleachRoi(:,:,currentSlice-1));
                end
                colorRoiData=double(bleachRoi)>0;
                sz=size(colorRoiData);
            case 'unbleached'
                if RoiImageType==2 % 3D
                    membraneRoi=squeeze(membraneRoi(:,:,currentSlice-1));
                end
                colorRoiData=double(membraneRoi)>0;
                sz=size(colorRoiData);
            case 'bg'
                if RoiImageType==2 % 3D
                    bgRoi=squeeze(bgRoi(:,:,currentSlice-1));
                end
                colorRoiData=double(bgRoi)>0;
                sz=size(colorRoiData);
        end
        sz=sz(1:2);
        colorRoiData3D=zeros(size(colorRoiData,1),size(colorRoiData,2),3);
        switch colorLetter
            case 'r'
                colorRoiData3D(:,:,1)=colorRoiData;
            case 'g'
                colorRoiData3D(:,:,2)=colorRoiData;
            case 'b'
                colorRoiData3D(:,:,3)=colorRoiData;
        end
        k=k+1;
        roiH(k)=imshow(colorRoiData3D);
        alphaMap=zeros(sz);
        alphaMap(colorRoiData>0)=faceAlpha;
        set(roiH(k),'alphadata',alphaMap)
    % shift of the coordinates by +0.5 is required because the axis limit starts from 0.5
    case 'Polygon'
        boundary=RoiStruct.roiData.Points;
        k=k+1;
        roiH(k)=fill(boundary(:,1)+0.5, boundary(:,2)+0.5,colorLetter,'edgecolor',colorLetter,'parent',axisH);
        if whichButton==1 % filled
            set(roiH(k),'facealpha',faceAlpha);
        else
            set(roiH(k),'facealpha',0);
        end
    case 'Bezier'
        boundary=RoiStruct.roiData.Points;
        points=getSplinePoints(boundary)';
        k=k+1;
        roiH(k)=fill(points(:,1)+0.5, points(:,2)+0.5,colorLetter,'edgecolor',colorLetter,'parent',axisH);
        if whichButton==1 % filled
            set(roiH(k),'facealpha',faceAlpha);
        else
            set(roiH(k),'facealpha',0);
        end
    case 'Ellipse'
        Rx=RoiStruct.roiData.RadiusX;
        Ry=RoiStruct.roiData.RadiusY;
        angles=linspace(0,2*pi-2*pi/720,720);
        X=Rx*cos(angles);
        Y=Ry*sin(angles);
        rotation=RoiStruct.roiData.Rotation*2*pi/360;
        roiX=RoiStruct.roiData.CenterX+X*cos(rotation)-Y*sin(rotation);
        roiY=RoiStruct.roiData.CenterY+X*sin(rotation)+Y*cos(rotation);
        k=k+1;
        roiH(k)=fill(roiX+0.5, roiY+0.5,colorLetter,'edgecolor',colorLetter,'parent',axisH);
        if whichButton==1 % filled
            set(roiH(k),'facealpha',faceAlpha);
        else
            set(roiH(k),'facealpha',0);
        end
    case 'Circle'
        theta=linspace(0,2*pi,720);
        radius=RoiStruct.roiData.Radius;
        xOrigin=RoiStruct.roiData.CenterX;
        yOrigin=RoiStruct.roiData.CenterY;
        xOfCircle=radius*sin(theta)+xOrigin;
        yOfCircle=radius*cos(theta)+yOrigin;
        k=k+1;
        roiH(k)=fill(xOfCircle+0.5, yOfCircle+0.5,colorLetter,'edgecolor',colorLetter,'parent',axisH);
        if whichButton==1 % filled
            set(roiH(k),'facealpha',faceAlpha);
        else
            set(roiH(k),'facealpha',0);
        end
end

function roiH=drawAllRois(bleachRoiStruct,membraneRoiStruct,bgRoiStruct,axisH,bleachRoi,membraneRoi,bgRoi,bleachRoiImageType,membraneRoiImageType,bgRoiImageType,whichButton,faceAlpha,currentSlice)
% currentSlice: from 1 to zSize
roiH=[];
if ~isempty(bleachRoiStruct)
    roiH=drawAllRoisSubroutine('r',bleachRoiStruct,bleachRoiImageType,axisH,bleachRoi,membraneRoi,bgRoi,faceAlpha,currentSlice,whichButton,'bleached');
end
if ~isempty(membraneRoiStruct)
    tempRoiH=drawAllRoisSubroutine('b',membraneRoiStruct,membraneRoiImageType,axisH,bleachRoi,membraneRoi,bgRoi,faceAlpha,currentSlice,whichButton,'unbleached');
    roiH=[roiH,tempRoiH];
end
if ~isempty(bgRoiStruct)
    tempRoiH=drawAllRoisSubroutine('g',bgRoiStruct,bgRoiImageType,axisH,bleachRoi,membraneRoi,bgRoi,faceAlpha,currentSlice,whichButton,'bg');
    roiH=[roiH,tempRoiH];
end

function roiImage=drawZeissRois(varargin)
% The function displays ROIs extracted from a Zeiss CZI file by the
% extractZeissRois function.
% roiImage=drawZeissRois(roiStructure, imageSize, outputType, filled, separateImages)
% OR
% roiImage=drawZeissRois(roiStructure, imageSize) defaults to 'dipimage' output type, filled ROIs in one image.
%
% roiStructure - a structure variable generated by extractZeissRois
% imageSize - a two-element array: [xSize,ySize], i.e. [horizontalSize,verticalSize]
% outputType - 'dipimage' or 'matlab' corresponding to a dip_image or a matlab numeric array, respectively
% filled - 1 or 0 corresponding to filled ROIs or only their circumference
% separateImage - 1 if each ROI is to be saved in a separate image. Otherwise all ROIs will be drawn in the same image.
%
% Peter Nagy, email: peter.v.nagy@gmail.com, https://peternagyweb.hu/
% V1.03
if nargin==2
    roiStructure=varargin{1};
    imageSize=varargin{2};
    outputType='dipimage';
    filled=true;
    separateImages=false;
else
    roiStructure=varargin{1};
    imageSize=varargin{2};
    outputType=varargin{3};
    filled=varargin{4};
    separateImages=varargin{5};
end
if ~ismember(outputType,{'dipimage','matlab'})
    error('outputType can only be ''dipimage'' or ''matlab''.');
end
if separateImages==1
    roiImage=zeros(imageSize(2),imageSize(1),numel(roiStructure));
else
    roiImage=zeros(imageSize(2),imageSize(1));
end
for i=1:numel(roiStructure)
    switch roiStructure(i).roiType
        case 'Rectangle'
            roiX=[roiStructure(i).roiData.Left roiStructure(i).roiData.Left roiStructure(i).roiData.Left+roiStructure(i).roiData.Width roiStructure(i).roiData.Left+roiStructure(i).roiData.Width];
            roiY=[roiStructure(i).roiData.Top roiStructure(i).roiData.Top+roiStructure(i).roiData.Height roiStructure(i).roiData.Top+roiStructure(i).roiData.Height roiStructure(i).roiData.Top];
        case 'Circle'
            angles=linspace(0,2*pi-2*pi/720,720);
            roiX=roiStructure(i).roiData.Radius*sin(angles)+roiStructure(i).roiData.CenterX;
            roiY=roiStructure(i).roiData.Radius*cos(angles)+roiStructure(i).roiData.CenterY;
        case 'Ellipse'
            a=roiStructure(i).roiData.RadiusX;
            b=roiStructure(i).roiData.RadiusY;
            angles=linspace(0,2*pi-2*pi/720,720);
            X=a*cos(angles);
            Y=b*sin(angles);
            rotation=roiStructure(i).roiData.Rotation*2*pi/360;
            roiX=roiStructure(i).roiData.CenterX+X*cos(rotation)-Y*sin(rotation);
            roiY=roiStructure(i).roiData.CenterY+X*sin(rotation)+Y*cos(rotation);
        case 'Polygon'
            roiX=roiStructure(i).roiData.Points(:,1);
            roiY=roiStructure(i).roiData.Points(:,2);
        case 'Bezier'
            points=getSplinePoints(roiStructure(i).roiData.Points)';
            roiX=points(:,1);
            roiY=points(:,2);
            % The next lines would draw the ROI as a Bezier curve.
            %closedRoiData=[roiStructure(i).roiData.Points;roiStructure(i).roiData.Points(1,:)];
            %Bez=GnBezierFit(closedRoiData',2,1);
            %Bez2=EvaluateBezierStruct(Bez,100);
            %for j=1:numel(Bez2)
            %    if j==1
            %        roiX=Bez2(j).X(1,:);
            %        roiY=Bez2(j).X(2,:);
            %    else
            %        roiX=[roiX,Bez2(j).X(1,:)];
            %        roiY=[roiY,Bez2(j).X(2,:)];
            %    end
            %end
    end
    if any(roiX>imageSize(2)) || any(roiY>imageSize(1)) % no checking for <1 because of strange ROIs appearing in CZI files
        errordlg('ROIs don''t fit on the image of the specified size.','Oops');
        roiImage=-1;
        return;
    end
    if filled==1
        [coord1,coord2]=meshgrid(1:imageSize(1),1:imageSize(2));
        coord1=reshape(coord1,numel(coord1),1);
        coord2=reshape(coord2,numel(coord2),1);
        insideIndices=inpolygon(coord2,coord1,roiY,roiX);
        currentRoi=reshape(insideIndices,imageSize(2),imageSize(1));
    else
        if iscolumn(roiX)
            roiX=[roiX;roiX(1)];
            roiY=[roiY;roiY(1)];
        else
            roiX=[roiX,roiX(1)];
            roiY=[roiY,roiY(1)];
        end
        [lineX,lineY]=line2Dcoordinates(roiX,roiY);
        currentRoi=zeros(imageSize(2),imageSize(1));
        if sum((round(lineX)-1)*imageSize(2)+round(lineY)>imageSize(1)*imageSize(2))==0 &&...
                sum((round(lineX)-1)*imageSize(2)+round(lineY)<0)==0 && sum(round(lineX)<0)==0 && sum(round(lineY)<0)==0
            pixelIndices=sub2ind([imageSize(2) imageSize(1)],round(lineY),round(lineX));
            currentRoi(pixelIndices)=1;
        end
    end
    if separateImages==1
        roiImage(:,:,i)=currentRoi;
    else
        roiImage=roiImage | currentRoi;
    end
end
if strcmp(outputType,'dipimage')
    roiImage=dip_image(roiImage);
end

function points=getSplinePoints(xy)
xy=[xy;xy(1,:)];
sp=cscvn(xy');
[points]=fnplt(sp,'r',2);

function [lineX,lineY]=line2Dcoordinates(x,y)
for i=1:numel(x)-1
    point1=[x(i) y(i)];
    point2=[x(i+1) y(i+1)];
    lengthOfLine=sqrt(sum((point1-point2).^2));
    t=linspace(0,1,lengthOfLine*10);
    coordinates=repmat(point1,length(t),1)'+(point2-point1)'*t;
    coordinates=round(coordinates)';
    if i==1
        coordinatesXY=coordinates;
    else
        coordinatesXY=[coordinatesXY;coordinates(2:end,:)];
    end
end
coordinatesXY=coordinatesXY(sum(diff([0 0;coordinatesXY]),2)~=0,:);
lineX=coordinatesXY(:,1);
lineY=coordinatesXY(:,2);

function select_roi_popup_callback(src,evt,axisH,importedRoiData,imageSize,roiTypeTextH)
delete(get(axisH,'children'));
roiSelected=get(src,'value');
roiImage1=drawZeissRois(importedRoiData(roiSelected), imageSize, 'matlab', 1, 0);
roiImage2=drawZeissRois(importedRoiData(1:numel(importedRoiData)~=roiSelected), imageSize, 'matlab', 0, 0);
roiImage=roiImage1 | roiImage2;
imshow(roiImage);
switch importedRoiData(roiSelected).roiType
    case {'Rectangle','Polygon','Circle','Ellipse','Bezier'}
        set(roiTypeTextH,'string',importedRoiData(roiSelected).roiType);
    otherwise
        set(roiTypeTextH,'string',[importedRoiData(roiSelected).roiType,' - unsupported']);
end

function roiSelected=selectROIsFromMany(importedRoiData,viewedImage)
scrsz=get(0,'ScreenSize');
dlgsz=[500 600];
selectionFH=figure('Name','Select a ROI','windowstyle','normal','toolbar','none','menubar','none','units','pixels','position',[(scrsz(3)-dlgsz(1))/2 (scrsz(4)-dlgsz(2))/2 dlgsz],'color',[0.9412 0.9412 0.9412],'NumberTitle','off','resize','off');
uicontrol('parent',selectionFH,'style','text','units','pixels','position',[10 dlgsz(2)-40 dlgsz(1)-20 20],'fontsize',10,'foregroundcolor','red','fontweight','bold','string','More than one ROI present. Choose which one to use.');
uicontrol('parent',selectionFH,'style','text','units','pixels','position',[dlgsz(1)/2-100 dlgsz(2)-70 100 20],'fontsize',10,'string','Chosen ROI');
numRois=numel(importedRoiData);
popupH=uicontrol('parent',selectionFH,'style','popupmenu','units','pixels','position',[dlgsz(1)/2+10 dlgsz(2)-70 50 20],'fontsize',10,'string',cellfun(@(x) num2str(x),num2cell(1:numRois),'uniformoutput',false));
imgDispSize=400;
axisH=axes('parent',selectionFH,'units','pixels','position',[(dlgsz(1)-imgDispSize)/2 dlgsz(2)-90-imgDispSize imgDispSize imgDispSize]);
if ~isfield(importedRoiData,'roiType') || ~isfield(importedRoiData,'roiData')
    errordlg('Specified ROI variable doesn''t contain the required fields, roiType and roiData.','Oops');
    roiSelected=nan;
    close(selectionFH);
    return;
end
try
    roiImage1=drawZeissRois(importedRoiData(1), [size(viewedImage,1) size(viewedImage,2)], 'matlab', 1, 0);
    if numel(roiImage1)==1 && roiImage1==-1
        roiSelected=nan;
        close(selectionFH);
        return;
    end
    roiImage2=drawZeissRois(importedRoiData(2:end), [size(viewedImage,1) size(viewedImage,2)], 'matlab', 0, 0);
    if numel(roiImage2)==1 && roiImage2==-1
        roiSelected=nan;
        close(selectionFH);
        return;
    end
catch
    errordlg('Error occurred with drawing ROIs.','Oops');
    roiSelected=nan;
    close(selectionFH);
    return;
end
if (numel(roiImage1)==1 && roiImage1==-1) || (numel(roiImage2)==1 && roiImage2==-1)
    roiSelected=nan;
    close(selectionFH);
    return;
end
roiImage=roiImage1 | roiImage2;
imshow(roiImage);
roiTypeTextH=uicontrol('parent',selectionFH,'style','text','units','pixels','position',[(dlgsz(1)-imgDispSize)/2 dlgsz(2)-90-imgDispSize-25 imgDispSize 20],'fontsize',10);
switch importedRoiData(1).roiType
    case {'Rectangle','Polygon','Circle','Ellipse','Bezier'}
        set(roiTypeTextH,'string',importedRoiData(1).roiType);
    otherwise
        set(roiTypeTextH,'string',[importedRoiData(1).roiType,' - unsupported']);
end
buttonsz=[170 40];
uicontrol('parent',selectionFH,'style','pushbutton','units','pixels','position',[(dlgsz(1)-buttonsz(1))/2 dlgsz(2)-90-imgDispSize-40-buttonsz(2) buttonsz],'fontsize',10,'string','Select the filled ROI','callback',{@select_ROI_callback,popupH});
set(popupH,'callback',{@select_roi_popup_callback,axisH,importedRoiData,[size(viewedImage,1) size(viewedImage,2)],roiTypeTextH});
selectionGuiData.roiSelected=1;
guidata(selectionFH,selectionGuiData);
uiwait(selectionFH);
try
    selectionGuiData=guidata(selectionFH);
    close(selectionFH);
catch
    eh=errordlg('The first ROI will be selected.','Oops','modal');
    selectionGuiData.roiSelected=1;
    uiwait(eh);
end
disp(['ROI SELECTION',newline,'ROI selected: ',num2str(selectionGuiData.roiSelected),newline]);
roiSelected=selectionGuiData.roiSelected;

function drawRoi_callback(src,evt,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,lth,handleOfMain)
guitempdata=guidata(handleOfMain);
whichButton=logical(cellfun(@(x) x,get(rbhs,'value')));
whichSource=get(rbhs(whichButton),'userdata');
[editableH,enableStatus]=getEditableStuff(get(src,'parent'));
switch guitempdata.drawState
    case {0,2} % draw never pressed previously, finish pressed, THIS IS WHEN THE USER STARTS DRAWING
        drawonName=get(drawonH,'string');
        if isempty(drawonName)
            errordlg('Name of image to draw on is empty','Oops','modal');
            return;
        end
        try
            guitempdata.viewedImage=evalin('base',drawonName);
        catch
            errordlg('Error reading image to draw on.','Oops','modal');
            return;
        end
        if ndims(guitempdata.viewedImage)~=2
            if ndims(guitempdata.viewedImage)==3
                guitempdata.viewedImage=squeeze(guitempdata.viewedImage(:,:,0));
            else
                errordlg('Image to draw on must be 2D or 3D.','Oops','modal');
                return;
            end
        end
        if whichSource==2 % imported ROI
            if guitempdata.drawState==0 % draw never pressed
                sourceRoiName=get(sourceRoiH,'string');
                if isempty(sourceRoiName)
                    errordlg('ROI variable name is empty.','Oops','modal');
                    return;
                end
                try
                    importedRoiData=evalin('base',sourceRoiName);
                catch
                    errordlg('Error reading ROI variable','Oops','modal');
                    return;
                end
                if isstruct(importedRoiData) % if ROI data is from a Zeiss CZI image
                    if numel(importedRoiData)>1 % if there are more than one ROIs
                        roiSelected=selectROIsFromMany(importedRoiData,guitempdata.viewedImage);
                        if isnan(roiSelected)
                            for i=1:numel(editableH)
                                set(editableH(i),'enable',enableStatus{i});
                            end
                            set(guitempdata.mainbuttonhandles,'enable','on');
                            disp('ROI HAS NOT BEEN SET.');
                            changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                            return;
                        end
                        importedRoiData=importedRoiData(roiSelected);
                    end
                    switch importedRoiData.roiType
                        case 'Polygon'
                            if iscell(importedRoiData.roiData.Points) % 3D ROI, ROI shifts in every slice
                                errordlg('3D ROI. I will use the first slice only','Oops');
                                guitempdata.currentRoiCoord1=importedRoiData.roiData.Points{1}(:,1)';
                                guitempdata.currentRoiCoord2=importedRoiData.roiData.Points{1}(:,2)';
                            else
                                guitempdata.currentRoiCoord1=importedRoiData.roiData.Points(:,1)';
                                guitempdata.currentRoiCoord2=importedRoiData.roiData.Points(:,2)';
                            end
                            guitempdata.currentRoiType=importedRoiData.roiType;
                        case 'Rectangle' % 3D ROI isn't possible in this case
                            guitempdata.currentRoiCoord1=[importedRoiData.roiData.Left importedRoiData.roiData.Left+importedRoiData.roiData.Width importedRoiData.roiData.Left+importedRoiData.roiData.Width importedRoiData.roiData.Left];
                            guitempdata.currentRoiCoord2=[importedRoiData.roiData.Top importedRoiData.roiData.Top importedRoiData.roiData.Top+importedRoiData.roiData.Height importedRoiData.roiData.Top+importedRoiData.roiData.Height];
                            guitempdata.currentRoiType='Polygon';
                        case 'Circle' % 3D ROI isn't possible in this case
                            guitempdata.currentRoiCoord1=[importedRoiData.roiData.CenterX importedRoiData.roiData.CenterX+importedRoiData.roiData.Radius];
                            guitempdata.currentRoiCoord2=[importedRoiData.roiData.CenterY importedRoiData.roiData.CenterY];
                            guitempdata.currentRoiType=importedRoiData.roiType;
                    end
                else % now only struct ROI variables are allowed
                    errordlg('ROI variable must be a structure.','Oops','modal');
                    return;
                end
                showText=['The imported ROI is displayed.',newline,'Click on a vertex to move it.',newline,...
                    'CTRL-click on a vertex to retain rectangular shape if the original ROI is rectangular.',newline,...
                    'SHIFT-click on a vertex to maintain aspect ratio if the original ROI is rectangular.',newline,...
                    'Click inside the ROI to move the whole object.',newline];
            end
        else % if whichSource==2
            if guitempdata.drawState==0 % draw never pressed
                guitempdata.currentRoiCoord1=[];
                guitempdata.currentRoiCoord2=[];
                switch whichSource
                    case 3 % polygon
                        showText=['Click where you would like to define a vertex of the polygon. Click on the first vertex to close the contour.',newline,...
                            'You can move the vertices by dragging them around. Click inside the ROI to move the whole object.',newline];
                        guitempdata.currentRoiType='Polygon';
                    case 4 % rectangle
                        showText=['Click and move the mouse to draw a rectangle ROI. Click on a vertex to move it.',newline,...
                            'SHIFT-click on a vertex to maintain aspect ratio. Click inside the ROI to move the whole object.',newline];
                        guitempdata.currentRoiType='Polygon';
                    case 5 % square
                        showText=['Click and move the mouse to draw a square ROI. Click on a vertex to move it.',newline,...
                            'Click inside the ROI to move the whole object.',newline];
                        guitempdata.currentRoiType='Polygon';
                    case 6 % circle
                        showText=['Click on the origin of the circle, then drag the mouse to draw a circle.',newline,...
                            'Release the mouse when finished.',newline];
                        guitempdata.currentRoiType='Circle';
                end
            end
        end
        % all error checks complete
        if guitempdata.drawState~=0
            showText=['Click on a key point(square) to move it.',newline];
        end
        disp(showText);
        guitempdata.drawState=1;
        set(src,'string','Finish');
        set(rbhs,'enable','off');
        set(sourceRoiH,'enable','off');
        set(drawonH,'enable','off');
        set(resultH,'enable','off');
        set(roiExportVariableH,'enable','off');
        set(setBleachH,'enable','off');
        set(guitempdata.mainbuttonhandles,'enable','off');
        if guitempdata.displayWindowHandle==0
            viewedImageData=double(guitempdata.viewedImage);
            guitempdata.displayWindowHandle=dipshow(guitempdata.viewedImage,[prctile(viewedImageData(:),1) prctile(viewedImageData(:),99)]);
            dipmapping(guitempdata.displayWindowHandle,'global');
            hold on;
        end
        if ~isempty(guitempdata.currentRoiCoord1) % draw ROI if not empty
            guitempdata=drawRoi(guitempdata,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain);
        else % set window callbacks
            ih=getImageAndAxisHandleOfFigure(guitempdata.displayWindowHandle);
            set(ih,'buttondownfcn',{@drawOnClick_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain});
            set(guitempdata.displayWindowHandle,'closerequestfcn',{@simulateFinishPress_callback,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain});
        end
    case 1 % draw pressed, THIS IS WHEN THE USER FINISHES DRAWING
        guitempdata.drawState=2;
        if ishandle(guitempdata.displayWindowHandle) && guitempdata.displayWindowHandle~=0
            delete(guitempdata.displayWindowHandle);
        end
        guitempdata.displayWindowHandle=0;
        set(src,'string','Draw');
        set(rbhs,'enable','on');
        if whichSource==2 % imported ROI
            set(sourceRoiH,'enable','on');
        end
        if guitempdata.finishedRoi==1
            set(setBleachH,'enable','on');
        else
            guitempdata.currentRoiCoord1=[];
            guitempdata.currentRoiCoord2=[];
        end
        set(drawonH,'enable','on');
        set(resultH,'enable','on');
        set(roiExportVariableH,'enable','on');
        set(guitempdata.mainbuttonhandles,'enable','on');
        guitempdata.roiVertexObjectH=[];
        guitempdata.roiEdgeObjectH=[];
        guitempdata.roiObjectH=[];
end
guidata(handleOfMain,guitempdata);

function drawOnClick_callback(src,evt,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain)
guitempdata=guidata(handleOfMain);
cp=get(gca,'currentpoint');
lastClick=[cp(1,1) cp(1,2)];
switch whichSource
    case 3 % polygon
        numOfVertices=numel(guitempdata.currentRoiCoord1);
        guitempdata.currentRoiCoord1(numOfVertices+1)=lastClick(1);
        guitempdata.currentRoiCoord2(numOfVertices+1)=lastClick(2);
        if numOfVertices>=1
            guitempdata.roiEdgeObjectH(numOfVertices)=line([guitempdata.currentRoiCoord1(numOfVertices) guitempdata.currentRoiCoord1(numOfVertices+1)],[guitempdata.currentRoiCoord2(numOfVertices) guitempdata.currentRoiCoord2(numOfVertices+1)],'color','g');
        end
        guitempdata.roiVertexObjectH(numOfVertices+1)=fill([guitempdata.currentRoiCoord1(numOfVertices+1)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(numOfVertices+1)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(numOfVertices+1)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(numOfVertices+1)+guitempdata.roiVertexSize/2],...
            [guitempdata.currentRoiCoord2(numOfVertices+1)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(numOfVertices+1)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(numOfVertices+1)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(numOfVertices+1)-guitempdata.roiVertexSize/2],'g','edgecolor','g');
        if numOfVertices==1
            set(guitempdata.roiVertexObjectH(1),'buttondownfcn',{@clickRoiVertexWhileDrawing_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain});
        end
        uistack(guitempdata.roiVertexObjectH(1),'top');
    case {4,5,6} % rectangle, square, circle
        guitempdata.currentRoiCoord1(1)=lastClick(1);
        guitempdata.currentRoiCoord2(1)=lastClick(2);
        guitempdata.firstClickXY=[0,0]; % necessary to report that something has been clicked
        guitempdata.currentAction='drawbox';
        set(src,'buttondownfcn','');
        set(guitempdata.displayWindowHandle,'WindowButtonUpFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'up'});
        set(guitempdata.displayWindowHandle,'WindowButtonMotionFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'motion'});
        set(guitempdata.displayWindowHandle,'closerequestfcn',{@simulateFinishPress_callback,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain});
end
guidata(handleOfMain,guitempdata);

function clickRoiVertexWhileDrawing_callback(src,evt,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain)
guitempdata=guidata(handleOfMain);
delete(guitempdata.roiVertexObjectH);
delete(guitempdata.roiEdgeObjectH);
ih=getImageAndAxisHandleOfFigure(guitempdata.displayWindowHandle);
set(ih,'buttondownfcn','');
guitempdata=drawRoi(guitempdata,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain);
guidata(handleOfMain,guitempdata);

function guitempdata=drawRoi(guitempdata,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain)
ih=getImageAndAxisHandleOfFigure(guitempdata.displayWindowHandle);
set(ih,'buttondownfcn',{@resetFigureMouseReleaseCallback,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain});
switch guitempdata.currentRoiType
    case 'Circle'
        for i=1:2
            guitempdata.roiVertexObjectH(i)=fill([guitempdata.currentRoiCoord1(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)+guitempdata.roiVertexSize/2],...
                [guitempdata.currentRoiCoord2(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)-guitempdata.roiVertexSize/2],'g','edgecolor','g');
        end
        set(guitempdata.roiVertexObjectH(2),'buttondownfcn',{@clickRoiVertex_callback,handleOfMain}); % the callback is only adjusted for the point on the circle, not the origin
        set(guitempdata.roiVertexObjectH(2),'userdata',i);
        radius=sqrt(diff(guitempdata.currentRoiCoord1)^2+diff(guitempdata.currentRoiCoord2)^2);
        theta=linspace(0,2*pi,720);
        xOfCircle=radius*sin(theta)+guitempdata.currentRoiCoord1(1);
        yOfCircle=radius*cos(theta)+guitempdata.currentRoiCoord2(1);
        guitempdata.roiObjectH=fill(xOfCircle,yOfCircle,'g','edgecolor','g');
        set(guitempdata.roiObjectH,'facealpha',0.2);
        set(guitempdata.roiObjectH,'buttondownfcn',{@clickRoiInside_callback,handleOfMain});
        guitempdata.roiEdgeObjectH(1)=line(xOfCircle,yOfCircle,'color','g');
        uistack(guitempdata.roiObjectH,'top');
        uistack(guitempdata.roiVertexObjectH(2),'top');
    case 'Polygon'
        guitempdata.roiObjectH=fill(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2,'g','edgecolor','g');
        set(guitempdata.roiObjectH,'facealpha',0.2);
        set(guitempdata.roiObjectH,'buttondownfcn',{@clickRoiInside_callback,handleOfMain});
        for i=1:numel(guitempdata.currentRoiCoord1)
            if i==numel(guitempdata.currentRoiCoord1)
                nextRoi=1;
            else
                nextRoi=i+1;
            end
            guitempdata.roiEdgeObjectH(i)=line([guitempdata.currentRoiCoord1(i) guitempdata.currentRoiCoord1(nextRoi)],[guitempdata.currentRoiCoord2(i) guitempdata.currentRoiCoord2(nextRoi)],'color','g');
            guitempdata.roiVertexObjectH(i)=fill([guitempdata.currentRoiCoord1(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord1(i)+guitempdata.roiVertexSize/2],...
                [guitempdata.currentRoiCoord2(i)-guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)+guitempdata.roiVertexSize/2 guitempdata.currentRoiCoord2(i)-guitempdata.roiVertexSize/2],'g','edgecolor','g');
            set(guitempdata.roiVertexObjectH(i),'buttondownfcn',{@clickRoiVertex_callback,handleOfMain});
            set(guitempdata.roiVertexObjectH(i),'userdata',i);
        end
        uistack(guitempdata.roiVertexObjectH,'top');
end
set(guitempdata.displayWindowHandle,'WindowButtonUpFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'up'});
set(guitempdata.displayWindowHandle,'WindowButtonMotionFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'motion'});
set(guitempdata.displayWindowHandle,'closerequestfcn',{@simulateFinishPress_callback,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain});
guitempdata.finishedRoi=1;

function resetFigureMouseReleaseCallback(src,evt,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain)
fh=get(get(src,'parent'),'parent');
set(fh,'WindowButtonUpFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'up'});
set(fh,'WindowButtonMotionFcn',{@imageButtonUpAndMotion_callback,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,'motion'});
set(fh,'closerequestfcn',{@simulateFinishPress_callback,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain});

function simulateFinishPress_callback(src,evt,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,whichSource,drawBleachH,setBleachH,handleOfMain)
delete(src);
try
    guitempdata=guidata(handleOfMain);
catch
    return;
end
guitempdata.drawState=2;
guitempdata.displayWindowHandle=0;
set(drawBleachH,'string','Draw');
set(rbhs,'enable','on');
if whichSource==2 % imported ROI
    set(sourceRoiH,'enable','on');
end
if guitempdata.finishedRoi==1
    set(setBleachH,'enable','on');
end
set(drawonH,'enable','on');
set(resultH,'enable','on');
set(roiExportVariableH,'enable','on');
guitempdata.roiVertexObjectH=[];
guitempdata.roiEdgeObjectH=[];
guitempdata.roiObjectH=[];
guidata(handleOfMain,guitempdata);

function imageButtonUpAndMotion_callback(src,evt,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain,typeOfFcn)
guitempdata=guidata(handleOfMain);
if ~isempty(guitempdata.firstClickXY)
    delete(guitempdata.roiObjectH);
    delete(guitempdata.roiEdgeObjectH);
    delete(guitempdata.roiVertexObjectH);
    rp=get(gca,'currentpoint');
    lastClick=[rp(1,1) rp(1,2)];
    switch guitempdata.currentAction
        case 'move'
            guitempdata.currentRoiCoord1=guitempdata.currentRoiCoord1+(lastClick(1)-guitempdata.firstClickXY(1));
            guitempdata.currentRoiCoord2=guitempdata.currentRoiCoord2+(lastClick(2)-guitempdata.firstClickXY(2));
            guitempdata.firstClickXY(1)=lastClick(1);
            guitempdata.firstClickXY(2)=lastClick(2);
        case 'resize'
            switch whichSource
                case 2 % imported ROI
                    switch guitempdata.selectiontype
                        case 'extend' % shift click
                            if isSquareBox(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2)
                                [guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2]=maintainAspectRatio(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2,guitempdata.whichselected,lastClick);
                            else
                                guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                                guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
                            end
                        case 'alt' % control click
                            if isSquareBox(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2)
                                old1=guitempdata.currentRoiCoord1(guitempdata.whichselected);
                                old2=guitempdata.currentRoiCoord2(guitempdata.whichselected);
                                guitempdata.currentRoiCoord1(guitempdata.currentRoiCoord1==old1)=lastClick(1);
                                guitempdata.currentRoiCoord2(guitempdata.currentRoiCoord2==old2)=lastClick(2);
                            else
                                guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                                guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
                            end
                        case 'normal'
                            guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                            guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
                    end
                case 3 % polygon
                    guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                    guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
                case 4 % rectangle
                    switch guitempdata.selectiontype
                        case 'extend' % shift click
                            if isSquareBox(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2)
                                [guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2]=maintainAspectRatio(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2,guitempdata.whichselected,lastClick);
                            else
                                guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                                guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
                            end
                        case 'normal'
                            old1=guitempdata.currentRoiCoord1(guitempdata.whichselected);
                            old2=guitempdata.currentRoiCoord2(guitempdata.whichselected);
                            if guitempdata.currentRoiCoord1(guitempdata.currentRoiCoord1~=old1)==lastClick(1)
                                lastClick(1)=lastClick(1)+1;
                            end
                            if guitempdata.currentRoiCoord2(guitempdata.currentRoiCoord2~=old2)==lastClick(2)
                                lastClick(2)=lastClick(2)+1;
                            end
                            guitempdata.currentRoiCoord1(guitempdata.currentRoiCoord1==old1)=lastClick(1);
                            guitempdata.currentRoiCoord2(guitempdata.currentRoiCoord2==old2)=lastClick(2);
                    end
                case 5 % square
                    [guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2]=maintainAspectRatio(guitempdata.currentRoiCoord1,guitempdata.currentRoiCoord2,guitempdata.whichselected,lastClick);
                case 6 % circle
                    guitempdata.currentRoiCoord1(guitempdata.whichselected)=lastClick(1);
                    guitempdata.currentRoiCoord2(guitempdata.whichselected)=lastClick(2);
            end
        case 'drawbox'
            switch whichSource
                case 4 % rectangle
                    if lastClick(1)==guitempdata.currentRoiCoord1(1)
                        lastClick(1)=guitempdata.currentRoiCoord1(1)+10;
                    end
                    if lastClick(2)==guitempdata.currentRoiCoord2(1)
                        lastClick(2)=guitempdata.currentRoiCoord2(1)+10;
                    end
                    guitempdata.currentRoiCoord1(2)=guitempdata.currentRoiCoord1(1);
                    guitempdata.currentRoiCoord1(3)=lastClick(1);
                    guitempdata.currentRoiCoord1(4)=lastClick(1);
                    guitempdata.currentRoiCoord2(2)=lastClick(2);
                    guitempdata.currentRoiCoord2(3)=lastClick(2);
                    guitempdata.currentRoiCoord2(4)=guitempdata.currentRoiCoord2(1);
                case 5 % square
                    if lastClick(1)==guitempdata.currentRoiCoord1(1)
                        lastClick(1)=guitempdata.currentRoiCoord1(1)+10;
                    end
                    if lastClick(2)==guitempdata.currentRoiCoord2(1)
                        lastClick(2)=guitempdata.currentRoiCoord2(1)+10;
                    end
                    width=lastClick(1)-guitempdata.currentRoiCoord1(1);
                    height=lastClick(2)-guitempdata.currentRoiCoord2(1);
                    if abs(width)<abs(height)
                        lengthOfSide=width;
                    else
                        lengthOfSide=height;
                    end
                    guitempdata.currentRoiCoord1(2)=guitempdata.currentRoiCoord1(1);
                    guitempdata.currentRoiCoord1(3)=guitempdata.currentRoiCoord1(1)+lengthOfSide;
                    guitempdata.currentRoiCoord1(4)=guitempdata.currentRoiCoord1(1)+lengthOfSide;
                    guitempdata.currentRoiCoord2(2)=guitempdata.currentRoiCoord2(1)+lengthOfSide;
                    guitempdata.currentRoiCoord2(3)=guitempdata.currentRoiCoord2(1)+lengthOfSide;
                    guitempdata.currentRoiCoord2(4)=guitempdata.currentRoiCoord2(1);
                case 6 % circle
                    if lastClick(1)==guitempdata.currentRoiCoord1(1)
                        lastClick(1)=guitempdata.currentRoiCoord1(1)+10;
                    end
                    if lastClick(2)==guitempdata.currentRoiCoord2(1)
                        lastClick(2)=guitempdata.currentRoiCoord2(1)+10;
                    end
                    guitempdata.currentRoiCoord1(2)=lastClick(1);
                    guitempdata.currentRoiCoord2(2)=lastClick(2);
            end
    end
    if strcmp(typeOfFcn,'up')
        guitempdata.firstClickXY=[];
    end
    guitempdata=drawRoi(guitempdata,whichSource,rbhs,sourceRoiH,drawonH,resultH,roiExportVariableH,drawBleachH,setBleachH,handleOfMain);
    guidata(handleOfMain,guitempdata);
end

function [newCoord1,newCoord2]=maintainAspectRatio(oldCoord1,oldCoord2,which,clickCoord)
newCoord1=oldCoord1;
newCoord2=oldCoord2;
oppositeIndex=mod(which-1+2,4)+1;
oldWidth=oldCoord1(which)-oldCoord1(oppositeIndex);
oldHeight=oldCoord2(which)-oldCoord2(oppositeIndex);
newWidth=clickCoord(1)-oldCoord1(oppositeIndex);
newHeight=clickCoord(2)-oldCoord2(oppositeIndex);
if ~(newWidth==0 || newHeight==0)
    if abs(newWidth/newHeight)>abs(oldWidth/oldHeight)
        newX=oldCoord1(oppositeIndex)+oldWidth*newHeight/oldHeight;
        newCoord1(oldCoord1==oldCoord1(which))=newX;
        newCoord2(oldCoord2==oldCoord2(which))=clickCoord(2);
    else
        newY=oldCoord2(oppositeIndex)+oldHeight*newWidth/oldWidth;
        newCoord1(oldCoord1==oldCoord1(which))=clickCoord(1);
        newCoord2(oldCoord2==oldCoord2(which))=newY;
    end
end

function result=isSquareBox(x,y)
if numel(x)~=4 || numel(y)~=4 || numel(unique(x))~=2 || numel(unique(y))~=2
    result=false;
else
    i=0;
    notFound=true;
    unX=unique(x);
    unY=unique(y);
    testX=[unX(1) unX(1) unX(2) unX(2)];
    testY=[unY(1) unY(2) unY(2) unY(1)];
    while i<=3 && notFound
        xShifted=circshift(x,[0,i]);
        j=0;
        while j<=3 && notFound
            yShifted=circshift(y,[0,j]);
            if isequal(xShifted,testX) && isequal(yShifted,testY)
                notFound=false;
            end
            j=j+1;
        end
        i=i+1;
    end
    if notFound
        result=false;
    else
        result=true;
    end
end

function clickRoiVertex_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
guitempdata.firstClickXY=[0,0]; % necessary to report that something has been clicked
guitempdata.selectiontype=get(guitempdata.displayWindowHandle,'selectiontype');
guitempdata.whichselected=get(src,'userdata');
guitempdata.currentAction='resize';
guidata(handleOfMain,guitempdata);

function clickRoiInside_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
cp=get(gca,'currentpoint');
guitempdata.firstClickXY=[cp(1,1) cp(1,2)];
guitempdata.currentAction='move';
guidata(handleOfMain,guitempdata);

function setRoi_callback(src,evt,rbhs,sourceImageH,sourceRoiH,drawonH,resultH,roiExportVariableH,fromWhere,lth,handleOfMain)
whichButton=logical(cellfun(@(x) x,get(rbhs,'value')));
whichSource=get(rbhs(whichButton),'userdata');
switch fromWhere
    case 'bleach'
        resultImageField='bleachRoi';
        resultRoiStruct='bleachRoiStruct';
        roiImageType='bleachRoiImageType';
        roiTypeMain='BLEACH';
        changeMessagePermanently(lth,'Setting bleaching ROI...',handleOfMain);
    case 'bg'
        resultImageField='bgRoi';
        resultRoiStruct='bgRoiStruct';
        roiImageType='bgRoiImageType';
        roiTypeMain='BACKGROUND';
        changeMessagePermanently(lth,'Setting background ROI...',handleOfMain);
    case 'membrane'
        resultImageField='membraneRoi';
        resultRoiStruct='membraneRoiStruct';
        roiImageType='membraneRoiImageType';
        roiTypeMain='UNBLEACHED';
        changeMessagePermanently(lth,'Setting unlbeached ROI...',handleOfMain);
end
guitempdata=guidata(handleOfMain);
set(guitempdata.mainbuttonhandles,'enable','off');
[editableH,enableStatus]=getEditableStuff(get(src,'parent'));
set(editableH,'enable','off');
drawnow;
guitempdata.(resultRoiStruct)=struct;
switch whichSource
    case 1 % image
        inputName=get(sourceImageH,'string');
        if isempty(inputName)
            errordlg('Source image name is empty.','Oops','modal');
            changeMessagePermanently(lth,'Nothing to do',handleOfMain);
            set(guitempdata.mainbuttonhandles,'enable','on');
            for i=1:numel(editableH)
                set(editableH(i),'enable',enableStatus{i});
            end
            return;
        end
        try
            inputImage=evalin('base',inputName);
        catch
            errordlg('Error reading source image.','Oops','modal');
            changeMessagePermanently(lth,'Nothing to do',handleOfMain);
            set(guitempdata.mainbuttonhandles,'enable','on');
            for i=1:numel(editableH)
                set(editableH(i),'enable',enableStatus{i});
            end
            return;
        end
        inputImage=inputImage>=1;
        if ndims(inputImage)==3 && size(inputImage,3)==1
            inputImage=squeeze(inputImage);
        end
        guitempdata.(resultImageField)=inputImage;
        guitempdata.(resultRoiStruct).roiType='Image';
        switch ndims(inputImage)
            case 2
                guitempdata.(resultRoiStruct).roiData.Boundaries=bwboundaries(double(inputImage)');
                guitempdata.(roiImageType)=1; % 2D mask
            case 3
                guitempdata.(roiImageType)=2; % 3D mask
                if strcmp(class(inputImage),'dip_image')
                    firstSlice=0;
                    lastSlice=size(inputImage,3)-1;
                else
                    firstSlice=1;
                    lastSlice=size(inputImage,3);
                end
                guitempdata.(resultRoiStruct).roiData.Boundaries=cell(size(inputImage,3),1);
                for i=firstSlice:lastSlice
                    currentSlice=squeeze(inputImage(:,:,i));
                    if firstSlice==0
                        k=i+1;
                    else
                        k=i;
                    end
                    guitempdata.(resultRoiStruct).roiData.Boundaries{k}=bwboundaries(double(currentSlice)');
                end
            otherwise
                errordlg('Mask image must be 2D or 3D.','Oops','modal');
                changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                set(guitempdata.mainbuttonhandles,'enable','on');
                for i=1:numel(editableH)
                    set(editableH(i),'enable',enableStatus{i});
                end
                return;
        end
        roiExportVarName=get(roiExportVariableH,'string');
        if ~isempty(roiExportVarName)
            if ~isvarname(roiExportVarName)
                errordlg('Variable name for storing ROI vertices is not a valid variable name.','Oops','modal');
            else
                assigninWithCheck(roiExportVarName,guitempdata.(resultRoiStruct));
            end
        end
    case {2,3,4,5,6} % ROI-based
        drawonName=get(drawonH,'string');
        if isempty(drawonName)
            errordlg('Name of image to draw on is empty','Oops','modal');
            changeMessagePermanently(lth,'Nothing to do',handleOfMain);
            set(guitempdata.mainbuttonhandles,'enable','on');
            for i=1:numel(editableH)
                set(editableH(i),'enable',enableStatus{i});
            end
            return;
        end
        try
            drawonImage=evalin('base',drawonName);
        catch
            errordlg('Error reading image to draw on.','Oops','modal');
            changeMessagePermanently(lth,'Nothing to do',handleOfMain);
            set(guitempdata.mainbuttonhandles,'enable','on');
            for i=1:numel(editableH)
                set(editableH(i),'enable',enableStatus{i});
            end
            return;
        end
        if ndims(drawonImage)~=2
            if ndims(drawonImage)==3
                drawonImage=squeeze(drawonImage(:,:,0));
            else
                errordlg('Image to draw on must be 2D or 3D.','Oops','modal');
                changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                set(guitempdata.mainbuttonhandles,'enable','on');
                for i=1:numel(editableH)
                    set(editableH(i),'enable',enableStatus{i});
                end
                return;
            end
        end
        if whichSource==2 % from imported ROI
            sourceRoiName=get(sourceRoiH,'string');
            if guitempdata.drawState==0 % draw never pressed
                if isempty(sourceRoiName)
                    errordlg('ROI variable name is empty.','Oops','modal');
                    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                    set(guitempdata.mainbuttonhandles,'enable','on');
                    for i=1:numel(editableH)
                        set(editableH(i),'enable',enableStatus{i});
                    end
                    return;
                end
                try
                    importedRoiData=evalin('base',sourceRoiName);
                catch
                    errordlg('Error reading ROI variable','Oops','modal');
                    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                    set(guitempdata.mainbuttonhandles,'enable','on');
                    for i=1:numel(editableH)
                        set(editableH(i),'enable',enableStatus{i});
                    end
                    return;
                end
                if ~isstruct(importedRoiData)
                    errordlg('ROI must be a structure.','Oops');
                    set(guitempdata.mainbuttonhandles,'enable','on');
                    for i=1:numel(editableH)
                        set(editableH(i),'enable',enableStatus{i});
                    end
                    return;
                end
                if numel(importedRoiData)>1
                    roiSelected=selectROIsFromMany(importedRoiData,drawonImage);
                    if isnan(roiSelected)
                        for i=1:numel(editableH)
                            set(editableH(i),'enable',enableStatus{i});
                        end
                        set(guitempdata.mainbuttonhandles,'enable','on');
                        disp('ROI HAS NOT BEEN SET.');
                        changeMessagePermanently(lth,'Nothing to do',handleOfMain);
                        return;
                    end
                    importedRoiData=importedRoiData(roiSelected);
                end
                switch importedRoiData.roiType
                    case 'Polygon'
                        if iscell(importedRoiData.roiData.Points) % 3D ROI, ROI shifts in every slice
                            errordlg('3D ROI. I will use the first slice only','Oops');
                            guitempdata.(resultRoiStruct)=importedRoiData{1};
                        else
                            guitempdata.(resultRoiStruct)=importedRoiData;
                        end
                        guitempdata.currentRoiType=importedRoiData.roiType;
                    case 'Rectangle' % 3D ROI isn't possible in this case
                        xCoord=[importedRoiData.roiData.Left importedRoiData.roiData.Left+importedRoiData.roiData.Width importedRoiData.roiData.Left+importedRoiData.roiData.Width importedRoiData.roiData.Left];
                        yCoord=[importedRoiData.roiData.Top importedRoiData.roiData.Top importedRoiData.roiData.Top+importedRoiData.roiData.Height importedRoiData.roiData.Top+importedRoiData.roiData.Height];
                        guitempdata.(resultRoiStruct).roiData.Points=[xCoord' yCoord'];
                        guitempdata.(resultRoiStruct).roiType='Polygon';
                    case 'Circle' % 3D ROI isn't possible in this case
                        guitempdata.(resultRoiStruct)=importedRoiData;
                    case 'Bezier'
                        guitempdata.(resultRoiStruct)=importedRoiData;
                        guitempdata.(resultRoiStruct).roiType='Bezier';
                    case 'Ellipse'
                        guitempdata.(resultRoiStruct)=importedRoiData;
                        guitempdata.(resultRoiStruct).roiType='Ellipse';
                end
                guitempdata.currentRoiType=guitempdata.(resultRoiStruct).roiType;
            else
                switch guitempdata.currentRoiType 
                    case 'Polygon'
                        guitempdata.(resultRoiStruct).roiType='Polygon';
                        guitempdata.(resultRoiStruct).roiData.Points=[guitempdata.currentRoiCoord1;guitempdata.currentRoiCoord2]';
                    case 'Circle'
                        guitempdata.(resultRoiStruct).roiType='Circle';
                        guitempdata.(resultRoiStruct).roiData.CenterX=guitempdata.currentRoiCoord1(1);
                        guitempdata.(resultRoiStruct).roiData.CenterY=guitempdata.currentRoiCoord2(1);
                        guitempdata.(resultRoiStruct).roiData.Radius=sqrt(diff(guitempdata.currentRoiCoord1)^2+diff(guitempdata.currentRoiCoord2)^2);
                end
            end
        else
            switch guitempdata.currentRoiType 
                case 'Polygon'
                    guitempdata.(resultRoiStruct).roiType='Polygon';
                    guitempdata.(resultRoiStruct).roiData.Points=[guitempdata.currentRoiCoord1;guitempdata.currentRoiCoord2]';
                case 'Circle'
                    guitempdata.(resultRoiStruct).roiType='Circle';
                    guitempdata.(resultRoiStruct).roiData.CenterX=guitempdata.currentRoiCoord1(1);
                    guitempdata.(resultRoiStruct).roiData.CenterY=guitempdata.currentRoiCoord2(1);
                    guitempdata.(resultRoiStruct).roiData.Radius=sqrt(diff(guitempdata.currentRoiCoord1)^2+diff(guitempdata.currentRoiCoord2)^2);
            end
        end
        [coord1,coord2]=meshgrid(1:size(drawonImage,1),1:size(drawonImage,2));
        coord1=reshape(coord1,numel(coord1),1);
        coord2=reshape(coord2,numel(coord2),1);
        switch guitempdata.currentRoiType 
            case 'Polygon'
                insideIndices=inpolygon(coord1,coord2,guitempdata.(resultRoiStruct).roiData.Points(:,1),guitempdata.(resultRoiStruct).roiData.Points(:,2));
                insideIndices=reshape(insideIndices,[size(drawonImage,2) size(drawonImage,1)]);
            case 'Circle'
                theta=linspace(0,2*pi,720);
                xOfCircle=guitempdata.(resultRoiStruct).roiData.Radius*sin(theta)+guitempdata.(resultRoiStruct).roiData.CenterX;
                yOfCircle=guitempdata.(resultRoiStruct).roiData.Radius*cos(theta)+guitempdata.(resultRoiStruct).roiData.CenterY;
                insideIndices=inpolygon(coord1,coord2,xOfCircle,yOfCircle);
                insideIndices=reshape(insideIndices,[size(drawonImage,2) size(drawonImage,1)]);
            case {'Bezier','Ellipse'}
                insideIndices=double(drawZeissRois(guitempdata.(resultRoiStruct),size(drawonImage)))>0;
        end
        guitempdata.(resultImageField)=dip_image(insideIndices);
        roiExportVarName=get(roiExportVariableH,'string');
        if ~isempty(roiExportVarName)
            if ~isvarname(roiExportVarName)
                errordlg('Variable name for storing ROI is not a valid variable name.','Oops','modal');
            else
                assigninWithCheck(roiExportVarName,guitempdata.(resultRoiStruct));
            end
        end
        outputName=get(resultH,'string');
        if ~isempty(outputName)
            if ~isvarname(outputName)
                errordlg('Variable name for the result image is not a valid Matlab variable name.','Oops','modal');
            else
                assigninWithCheck(outputName,guitempdata.(resultImageField));
                evalin('base',outputName);
            end
        end
        guitempdata.(roiImageType)=1; % 2D mask
end
guitempdata.drawState=0;
switch whichSource
    case 1
        if ndims(inputImage)==2
            roiType=['2D image, variable: ',inputName];
        else
            roiType=['3D image, variable: ',inputName];
        end
    case 2
        roiType=['imported ROI, variable: ',sourceRoiName];
    case 3
        roiType='polygon';
    case 4
        roiType='rectangle';
    case 5
        roiType='square';
    case 6
        roiType='circle';
end
reportText=[roiTypeMain,' ROI HAS BEEN SET.',newline,'Source of ROI: ',roiType,newline];
if ~isempty(roiExportVarName) && isvarname(roiExportVarName)
    reportText=[reportText,'ROI stored in variable ',roiExportVarName,'.',newline];
end
if ismember(whichSource,[2 3 4 5]) && ~isempty(outputName) && isvarname(outputName)
    reportText=[reportText,'Mask image stored in variable ',outputName,'.',newline];
end
disp(reportText);
guidata(handleOfMain,guitempdata);
switch fromWhere
    case 'bleach'
        displayTimedMessage('Bleaching ROI set',lth,3,handleOfMain);
    case 'bg'
        displayTimedMessage('Background ROI set',lth,3,handleOfMain);
    case 'membrane'
        displayTimedMessage('Unbleached ROI set',lth,3,handleOfMain);
end
set(guitempdata.mainbuttonhandles,'enable','on');
% set(editableH,cellfun(@(x) 'enable',cell(numel(editableH),1),'UniformOutput',false),enableStatus');
for i=1:numel(editableH)
    set(editableH(i),'enable',enableStatus{i});
end
drawnow;

function roiSource_callback(src,evt,sourceImageH,sourceRoiH,drawonH,resultH,roiVariableH,rbhs,drawH,setH,handleOfMain)
guitempdata=guidata(handleOfMain);
guitempdata.drawState=0;
guitempdata.currentRoiCoord1=[];
guitempdata.currentRoiCoord2=[];
guitempdata.finishedRoi=0;
whichButton=logical(cellfun(@(x) x,get(rbhs,'value')));
whichSource=get(rbhs(whichButton),'userdata');
switch whichSource
    case 1 % image
        set(setH,'enable','on');
        set(drawH,'enable','off');
        set(sourceImageH,'enable','on');
        set(sourceRoiH,'enable','off');
        set(drawonH,'enable','off');
        set(resultH,'enable','off');
        set(roiVariableH,'enable','on');
    case 2 % ROI
        set(setH,'enable','on');
        set(drawH,'enable','on');
        set(sourceImageH,'enable','off');
        set(sourceRoiH,'enable','on');
        set(drawonH,'enable','on');
        set(resultH,'enable','on');
        set(roiVariableH,'enable','on');
    otherwise
        set(setH,'enable','off');
        set(drawH,'enable','on');
        set(sourceImageH,'enable','off');
        set(sourceRoiH,'enable','off');
        set(drawonH,'enable','on');
        set(resultH,'enable','on');
        set(roiVariableH,'enable','on');
end
guidata(handleOfMain,guitempdata);

function exportImages_callback(src,evt,inputSmoothEditHandle,outputSmoothEditHandle,sliderSmoothHandle,rbSliceWhole,gaussSmoothEditHandle,lth,handleOfMain)
inputName=get(inputSmoothEditHandle,'string');
if isempty(inputName)
    errordlg('Source image name is empty.','Oops','modal');
    return;
end
outputName=get(outputSmoothEditHandle,'string');
if isempty(outputName)
    errordlg('Result image name is empty.','Oops','modal');
    return;
end
if ~isvarname(outputName)
    errordlg('Variable name for result image is not a valid variable name.','Oops');
    return;
end
try
    inputImage=evalin('base',inputName);
catch
    errordlg('Error reading source image.','Oops','modal');
    return;
end
gaussSD=str2double(get(gaussSmoothEditHandle,'string'));
if isnan(gaussSD)
    gaussSD=0;
end
outputImage=gaussf(inputImage,gaussSD);
radioSelection=find(cellfun(@(x) x,get(rbSliceWhole,'value')));
if radioSelection==1 % single slice
    if size(outputImage,3)>1
        whichSlice=round(get(sliderSmoothHandle,'value'));
        decision=assigninWithCheck(outputName,squeeze(outputImage(:,:,whichSlice-1)));
    else
        decision=assigninWithCheck(outputName,squeeze(outputImage));
    end
    radioText='Single slice was exported';
else % whole stack
    decision=assigninWithCheck(outputName,outputImage);
    radioText='Whole stack was exported';
end
if strcmp(decision,'Yes')
    fh=dipshow(outputImage,'lin');
    dipmapping(fh,'global');
    reportText=['SMOOTH AND EXPORT IMAGES',newline,'Source image: ',inputName,newline,'Result image: ',outputName,newline,'SD of Gaussian: ',num2str(gaussSD),newline,radioText,newline];
    if radioSelection==1
        if size(outputImage,3)>1
            reportText=[reportText,'Slice exported: ',num2str(whichSlice),newline];
        else
            reportText=[reportText,'Image was 2D.',newline];
        end
    end
    disp(reportText);
    displayTimedMessage('Image exported',lth,3,handleOfMain);
else
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
end

function gauss_callback(src,evt,handleOfMain)
guitempdata=guidata(handleOfMain);
if ~isempty(guitempdata.viewedImage)
    gaussSD=str2double(get(src,'string'));
    if isnan(gaussSD)
        gaussSD=0;
    end
    inputImage=gaussf(guitempdata.viewedImage,gaussSD);
    dipshow(guitempdata.displayWindowHandle,inputImage);
end

function simulateFinishPress2_callback(src,evt,buttonHandle,sliderSmoothHandle,inputSmoothEditHandle,exportH,handleOfMain)
delete(src);
if ishandle(handleOfMain)
    guitempdata=guidata(handleOfMain);
else
    return;
end
set(buttonHandle,'string','Start viewing');
set(buttonHandle,'userdata',0);
set(sliderSmoothHandle,'enable','off');
set(inputSmoothEditHandle,'enable','on');
set(exportH,'enable','on');
guitempdata.displayWindowHandle=0;
guitempdata.viewedImage=[];
guidata(handleOfMain,guitempdata);

function sliderSmooth_callback(obj,evt,src,sliceTextHandle,handleOfMain)
guitempdata=guidata(handleOfMain);
currentSlice=round(get(src,'value'));
dipshow(guitempdata.displayWindowHandle,'ch_slice',currentSlice-1);
set(sliceTextHandle,'string',num2str(currentSlice));

function registerImages_callback(src,evt,inputRegisterEditHandle,outputRegisterEditHandle,outputShiftEditHandle,lth,handleOfMain)
changeMessagePermanently(lth,'Registering images...',handleOfMain);
gd=guidata(handleOfMain);
set(gd.mainbuttonhandles,'enable','off');
[editableH,enableStatus]=getEditableStuff(get(src,'parent'));
set(editableH,'enable','off');
drawnow;
inputImageName=get(inputRegisterEditHandle,'string');
if isempty(inputImageName)
    errordlg('Source image name is emtpy.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    set(gd.mainbuttonhandles,'enable','on');
    for i=1:numel(editableH)
        set(editableH(i),'enable',enableStatus{i});
    end
    return;
end
outputImageName=get(outputRegisterEditHandle,'string');
outputShiftName=get(outputShiftEditHandle,'string');
if isempty(outputImageName)
    errordlg('Result image name is emtpy.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    set(gd.mainbuttonhandles,'enable','on');
    for i=1:numel(editableH)
        set(editableH(i),'enable',enableStatus{i});
    end
    return;
end
if ~isvarname(outputImageName)
    errordlg('Result image name is not a valid Matlab variable name.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    set(gd.mainbuttonhandles,'enable','on');
    for i=1:numel(editableH)
        set(editableH(i),'enable',enableStatus{i});
    end
    return;
end
if ~isempty(outputShiftName) && ~isvarname(outputShiftName)
    errordlg('The variable name for the shift vector is not a valid Matlab variable name.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    set(gd.mainbuttonhandles,'enable','on');
    for i=1:numel(editableH)
        set(editableH(i),'enable',enableStatus{i});
    end
    return;
end
try
    inputImage=evalin('base',inputImageName);
catch
    errordlg('Error reading source image','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
[outputImage,shiftVector]=correctshift(inputImage,0,0);
switch isempty(outputShiftName)
    case false % outputShiftName is not empty
        decision=assigninWithCheck({outputImageName,outputShiftName},{outputImage,shiftVector});
    case true % outputShiftName is empty
        decision=assigninWithCheck(outputImageName,outputImage);
end
if strcmp(decision,'Yes')
    fh=dipshow(outputImage,'lin');
    dipmapping(fh,'global');
    reportText=['IMAGE REGISTRATION',newline,'Source image: ',inputImageName,newline,'Result image: ',outputImageName,newline,'Shift vector: ',outputShiftName,newline];
    disp(reportText);
    displayTimedMessage('Images registered',lth,3,handleOfMain);
else
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
end
set(gd.mainbuttonhandles,'enable','on');
for i=1:numel(editableH)
    set(editableH(i),'enable',enableStatus{i});
end

function readRoiData_callback(src,evt,roiTextHandles,roiVarNameEditHandle,lth,handleOfMain)
changeMessagePermanently(lth,'Reading ROI...',handleOfMain);
varName=get(roiVarNameEditHandle,'string');
if isempty(varName)
    errordlg('Variable name for ROI is empty.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
if ~isvarname(varName)
    errordlg('Variable name for storing ROI vertices is not a valid Matlab variable','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
guitempdata=guidata(handleOfMain);
set(guitempdata.mainbuttonhandles,'enable','off');
[editableH,enableStatus]=getEditableStuff(get(src,'parent'));
set(editableH,'enable','off');
[filename,pathname]=uigetfile({'*.roi;*.ROI','ROI files (*.roi,*.ROI)';'*.*','All files'},'Select the ROI file',guitempdata.imagefilepath);
if ~filename==0
    fullfilename=[pathname,filename];
    if ischar(fullfilename)
        guitempdata.imagefilepath=pathname;
    end
    warning('off','MATLAB:iofun:UnsupportedEncoding');
    fileID=fopen(fullfilename,'r','n','unicode');
    fileText=textscan(fileID,'%s','delimiter','\n');
    fileText=fileText{1};
    fclose(fileID);
    warning('on','MATLAB:iofun:UnsupportedEncoding');
    firstLines=findSubstringInCellArray(fileText,'[ROIBase FileInformation]',1);
    roiData=cell(numel(firstLines),1);
    for i=1:numel(firstLines)
        if i==numel(firstLines)
            roiData{i}=fileText(firstLines(i):end);
        else
            roiData{i}=fileText(firstLines(i):firstLines(i+1)-1);
        end
    end
    bleachVal=zeros(numel(roiData),1);
    for i=1:numel(roiData)
        bleachTextPos=findSubstringInCellArray(roiData{i},'BLEACH',1);
        placeOfEqualSign=find(roiData{i}{bleachTextPos(1)}=='=');
        bleachVal(i)=str2double(roiData{i}{bleachTextPos(1)}(placeOfEqualSign+1:end));
    end
    whichIsBleach=find(bleachVal);
    if isempty(whichIsBleach)
        errordlg('No bleaching information present in ROI.','Oops','modal');
        changeMessagePermanently(lth,'Nothing to do',handleOfMain);
        return;
    end
    shapeTextPos=findSubstringInCellArray(roiData{whichIsBleach},'SHAPE',1);
    placeOfEqualSign=find(roiData{whichIsBleach}{shapeTextPos(1)}=='=');
    shapeData=str2double(roiData{whichIsBleach}{shapeTextPos(1)}(placeOfEqualSign+1:end));
    xTextPos=findSubstringInCellArray(roiData{whichIsBleach},'X=',1);
    placeOfEqualSign=find(roiData{whichIsBleach}{xTextPos(1)}=='=');
    xData=roiData{whichIsBleach}{xTextPos(1)}(placeOfEqualSign+1:end);
    yTextPos=findSubstringInCellArray(roiData{whichIsBleach},'Y=',1);
    placeOfEqualSign=find(roiData{whichIsBleach}{yTextPos(1)}=='=');
    yData=roiData{whichIsBleach}{yTextPos(1)}(placeOfEqualSign+1:end);
    xData=strsplit(xData,',');
    yData=strsplit(yData,',');
    xData=cellfun(@(x) str2double(x),xData)+1;
    yData=cellfun(@(x) str2double(x),yData)+1;
    bleachRoiStruct.roiType='Polygon';
    switch shapeData
        case 5 % rectangular
            bleachRoiCoord1=[xData(1) xData(2) xData(2) xData(1)];
            bleachRoiCoord2=[yData(1) yData(1) yData(2) yData(2)];
        case 8 % polygon
            bleachRoiCoord1=xData;
            bleachRoiCoord2=yData;
    end
    bleachRoiStruct.roiData.Points=[bleachRoiCoord1;bleachRoiCoord2]';
    set(roiTextHandles(1),'string',num2str(bleachRoiCoord1));
    set(roiTextHandles(2),'string',num2str(bleachRoiCoord2));
    decision=assigninWithCheck(varName,bleachRoiStruct);
    if ischar(guitempdata.imagefilepath) && ~isempty(guitempdata.imagefilepath)
        assignin('base','imagefilepath_frapfit',guitempdata.imagefilepath);
    end
    if strcmp(decision,'Yes')
        reportText=['READING BLEACHING ROI DATA',newline,'ROI file: ',fullfilename,newline,'Output variable: ',varName,newline];
        disp(reportText);
        displayTimedMessage('ROI read',lth,3,handleOfMain);
    else
        changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    end
    guidata(handleOfMain,guitempdata);
end
set(guitempdata.mainbuttonhandles,'enable','on');
for i=1:numel(editableH)
    set(editableH(i),'enable',enableStatus{i});
end

function setButtonPositions(buttonHandles,buttonSize,verticalSpacing,verticalTop,leftPos)
buttomPos=verticalTop;
for i=1:numel(buttonHandles)
    set(buttonHandles(i),'position',[leftPos buttomPos buttonSize]);
    buttomPos=buttomPos-verticalSpacing-buttonSize(2);
end

function button_callback(src,evt,handleOfMain,whichButton,allRbhs,bhsToChange)
setPanelVisibility(whichButton,handleOfMain);
guitempdata=guidata(handleOfMain);
guitempdata.currentRoiCoord1=[];
guitempdata.currentRoiCoord2=[];
guitempdata.roiVertexObjectH=[];
guitempdata.roiEdgeObjectH=[];
guitempdata.roiObjectH=[];
guitempdata.drawState=0;
guitempdata.finishedRoi=0;
guitempdata.viewedImage=[];
guitempdata.displayWindowHandle=0;
if ismember(whichButton,[5 6 7])
    whichRadioButton=logical(cellfun(@(x) x,get(allRbhs(whichButton-4,:),'value')));
    whichSource=get(allRbhs(whichButton-4,whichRadioButton),'userdata');
    switch whichSource
        case 1 % image
            set(guitempdata.drawBleachH(whichButton),'enable','off');
            set(guitempdata.setBleachH(whichButton),'enable','on');
        case 2 % imported ROI
            set(guitempdata.drawBleachH(whichButton),'enable','on');
            set(guitempdata.setBleachH(whichButton),'enable','on');
        otherwise % drawn ROI
            set(guitempdata.drawBleachH(whichButton),'enable','on');
            set(guitempdata.setBleachH(whichButton),'enable','off');
    end
end
for i=1:numel(bhsToChange)
    origText=get(bhsToChange(i),'userdata');
    if bhsToChange(i)==src
        newText=['<HTML><center><FONT color="red"><b>',origText,'</Font></b>'];
    else
        newText=origText;
    end
    set(bhsToChange(i),'string',newText);
end
guidata(handleOfMain,guitempdata);

function setPanelVisibility(whichPanel,handleOfMain)
guitempdata=guidata(handleOfMain);
ph=guitempdata.mainpanelhandles;
set(ph(1:numel(ph)~=whichPanel),'visible','off');
set(ph(whichPanel),'visible','on');

function mouseOverTarget_callback(src,eventdata,ph)
currentValueOfUserData=get(ph,'userdata');
cp=get(src,'CurrentPoint');
phPosition=get(ph,'position');
if cp(1)>phPosition(1) && cp(1)<phPosition(1)+phPosition(3) && cp(2)>phPosition(2) && cp(2)<phPosition(2)+phPosition(4)
    set(src,'pointer','hand');
    if currentValueOfUserData==0
        set(ph,'String','Email: peter.v.nagy@gmail.com');
        set(ph,'userdata',2);
        set(ph,'ButtonDownFcn',{@peternagy_callback,'mailto:peter.v.nagy@gmail.com'});
    elseif currentValueOfUserData==1
        set(ph,'String','https://peternagyweb.hu');
        set(ph,'userdata',3);
        set(ph,'ButtonDownFcn',{@peternagy_callback,'https://peternagyweb.hu'});
    end
else
    set(src,'pointer','arrow');
    set(ph,'string','Written by Peter Nagy');
    set(ph,'ButtonDownFcn','');
    if currentValueOfUserData>1
        set(ph,'userdata',3-currentValueOfUserData);
    end
end

function peternagy_callback(src,evtdata,link)
web(link,'-browser');

function select_file_callback(src,evt,fnTextHandle,handleOfMain)
guitempdata=guidata(handleOfMain);
[filename,pathname]=uigetfile({'*.tif;*.tiff','TIFF files (*.tif,*.tiff)';'*.jpg;*.jpeg','JPEG files (*.jpg,*.jpeg)';'*.*','All files'},'Select one of the files to be imported',guitempdata.imagefilepath);
fullfilename=[pathname,filename];
if ischar(fullfilename)
    set(fnTextHandle,'String',fullfilename);
    guitempdata.imagefilepath=pathname;
end
guidata(handleOfMain,guitempdata);

function allRois=extractRoiInfomationFromZeiss(hashTable,ignoreStrangeROIs)
% ignoreStrangeROIs - if true, ROIs whose all data fields are less than
% +/- 0.01 are ignored. Such ROIs pop up in the CZI files.
allKeys = arrayfun(@char, hashTable.keySet.toArray, 'UniformOutput', false);
allValues = cellfun(@(x) hashTable.get(x), allKeys, 'UniformOutput', false);
% define ROI definitions
roiTypes={'Rectangle','Circle','Ellipse','Polygon','Bezier'};
roiDefinitionStrings.Rectangle{1}='Global Layer|Rectangle|Geometry|Top';
roiDefinitionStrings.Rectangle{2}='Global Layer|Rectangle|Geometry|Left';
roiDefinitionStrings.Rectangle{3}='Global Layer|Rectangle|Geometry|Width';
roiDefinitionStrings.Rectangle{4}='Global Layer|Rectangle|Geometry|Height';
roiDefinitionStrings.Circle{1}='Global Layer|Circle|Geometry|CenterX';
roiDefinitionStrings.Circle{2}='Global Layer|Circle|Geometry|CenterY';
roiDefinitionStrings.Circle{3}='Global Layer|Circle|Geometry|Radius';
roiDefinitionStrings.Ellipse{1}='Global Layer|Ellipse|Geometry|CenterX';
roiDefinitionStrings.Ellipse{2}='Global Layer|Ellipse|Geometry|CenterY';
roiDefinitionStrings.Ellipse{3}='Global Layer|Ellipse|Geometry|RadiusX'; 
roiDefinitionStrings.Ellipse{4}='Global Layer|Ellipse|Geometry|RadiusY'; 
roiDefinitionStrings.Ellipse{5}='Global Layer|Ellipse|Rotation';
roiDefinitionStrings.Polygon{1}='Global Layer|ClosedPolyline|Geometry|Points';
roiDefinitionStrings.Bezier{1}='Global Layer|ClosedBezier|Geometry|Points';
% search for all recognized ROI types
R=cellfun(@(x) roiDefinitionStrings.(x),roiTypes,'UniformOutput',false);
searchFields=cellfun(@(x) x{1},R,'uniformoutput',false);
q=cellfun(@(x) findSubstringInCellArray(allKeys,x,1),searchFields,'uniformoutput',false);
numOfRois=numel(vertcat(q{:}));
if numOfRois>0
    currDir=pwd; % in order to ensure that 'split' does not execute the dipimage version of split
    cd([matlabroot,filesep,'toolbox',filesep,'matlab',filesep,'strfun']);
    allRois(numOfRois,1)=struct;
    % search for individual ROIs
    roiCounter=0;
    for i=1:numel(roiTypes)
        switch roiTypes{i}
            case {'Rectangle','Circle','Ellipse','Polygon'}
                for j=1:numel(roiDefinitionStrings.(roiTypes{i}))
                    [indices,strings]=findSubstringInCellArray(allKeys,roiDefinitionStrings.(roiTypes{i}){j},1);
                    posOfHash=cellfun(@(x) strfind(x,'#'),strings,'UniformOutput',false);
                    posOfHash=cell2mat(posOfHash);
                    if isempty(posOfHash)
                        emptyHash=true;
                    else
                        emptyHash=false;
                    end
                    localCounter=numel(strings);
                    parameterName=strfind(roiDefinitionStrings.(roiTypes{i}){j},'|');
                    parameterName=roiDefinitionStrings.(roiTypes{i}){j}(parameterName(end)+1:end);
                    for k=1:localCounter
                        if emptyHash
                            localNumber=1;
                        else
                            localNumber=str2double(strings{k}(posOfHash(k)+1:end));
                        end
                        allRois(roiCounter+localNumber).roiType=roiTypes{i};
                        switch roiTypes{i}
                            case {'Rectangle','Circle','Ellipse'}
                                allRois(roiCounter+localNumber).roiData.(parameterName)=str2double(allValues{indices(k)});
                            case 'Polygon'
                                pointXY=split(allValues{indices(k)},{',',' '});
                                pointXY=cellfun(@(x) str2double(x),pointXY);
                                pointXY=reshape(pointXY,[2 numel(pointXY)/2])';
                                allRois(roiCounter+localNumber).roiData.(parameterName)=pointXY;
                        end
                    end
                end
            case 'Bezier'
                [indices,strings]=findSubstringInCellArray(allKeys,roiDefinitionStrings.(roiTypes{i}),1);
                localCounter=numel(strings);
                for k=1:localCounter
                    allRois(roiCounter+k).roiType=roiTypes{i};
                    coords=cellfun(@(x) str2double(x),split(allValues{indices(k)},{' ',','}));
                    coords=reshape(coords,[2 numel(coords)/2])';
                    allRois(roiCounter+k).roiData.Points=coords;
                end
        end
        roiCounter=roiCounter+localCounter;
    end
    cd(currDir);
    % remove strange ROIs
    % Rectangle: Top, Left, Width, Height
    % Circle: CenterX, CenterY, Radius
    % Ellipse: CenterX, CenterY, RadiusX, RadiusY, Rotation (rotation is not nonses)
    % Polygon, Bezier: Points
    if ignoreStrangeROIs
        i=1;
        while i<=numel(allRois)
            switch allRois(i).roiType
                case {'Rectangle','Circle'}
                    roiDataTemp=structfun(@(x) x,allRois(i).roiData);
                case 'Ellipse'
                    roiDataTemp=[allRois(i).roiData.CenterX, allRois(i).roiData.CenterY, allRois(i).roiData.RadiusX, allRois(i).roiData.RadiusY];
                case {'Polygon','Bezier'}
                    roiDataTemp=allRois(i).roiData.Points(:);   
            end
            if all(abs(roiDataTemp)<0.1)
                allRois(i)=[];
            else
                i=i+1;
            end
        end
    end
else
    allRois=[];
end

function [indices,strings,positionsInStrings]=findSubstringInCellArray(cellArray,substring,caseSensitive)
if caseSensitive==0
    cellArray=lower(cellArray);
    substring=lower(substring);
end
logicals=strfind(cellArray,substring);
indices=find(cellfun(@(x) ~isempty(x),logicals));
strings=cellArray(indices);
positionsInStrings=cell2mat(logicals(indices));

function color=extractSliceNumber(string)
cPlace=strfind(string,'C=');
slashPlace=strfind(string(cPlace+2:end),'/');
color=str2double(string(cPlace+2:cPlace+2+slashPlace(1)-2));

function [imageData,roiData]=readCZIWithBioFormats(fullPathToImage)
imagePlusData=bfopen(fullPathToImage);
roiData=extractRoiInfomationFromZeiss(imagePlusData{2},true);
imageData=cell2mat(imagePlusData{1}(:,1));
imageData=permute(imageData,[2 1]);
imageData=reshape(imageData,[size(imagePlusData{1}{1,1},2) size(imagePlusData{1}{1,1},1) size(imagePlusData{1},1)]);
imageData=permute(imageData,[2 1 3:ndims(imageData)]);
descriptor=imagePlusData{1}(:,2);
if ~isempty(strfind(descriptor{1},'C=')) % if the image is a color stack
    colorNumbers=cellfun(@(x) extractSliceNumber(x),descriptor);
    colorNumbers=unique(colorNumbers);
    if numel(colorNumbers)>1
        imageDataTemp=cell(numel(colorNumbers),1);
        slicesFirstColor=1:numel(colorNumbers):size(imageData,3);
        for i=1:numel(colorNumbers)
            imageDataTemp{i}=imageData(:,:,slicesFirstColor+i-1);
        end
        imageData=imageDataTemp;
    end
end

function readCziDoIt_callback(src,evt,imageVarNameHandle,roiVarNameHandle,lth,seqSubpanel,handleOfMain)
imageVarName=get(imageVarNameHandle,'string');
if isempty(imageVarName)
    errordlg('Variable name is empty.','Oops','modal');
    return;
end
changeMessagePermanently(lth,'Reading images...',handleOfMain);
guitempdata=guidata(handleOfMain);
set(guitempdata.mainbuttonhandles,'enable','off');
[editableH1,enableStatus1]=getEditableStuff(get(src,'parent'));
[editableH2,enableStatus2]=getEditableStuff(seqSubpanel);
set(editableH1,'enable','off');
set(editableH2,'enable','off');
drawnow;
[filename,pathname]=uigetfile({'*.czi;*.CZI','CZI files (*.czi,*.CZI)';'*.*','All files'},'Select a Zeiss CZI file',guitempdata.imagefilepath);
if filename==0
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    set(guitempdata.mainbuttonhandles,'enable','on');
    set(editableH1,cellfun(@(x) 'enable',cell(numel(editableH1),1),'UniformOutput',false),enableStatus1');
    set(editableH2,cellfun(@(x) 'enable',cell(numel(editableH2),1),'UniformOutput',false),enableStatus2');
    return;
end
roiVarName=get(roiVarNameHandle,'string');
fullfilename=[pathname,filename];
[imageData,roiData]=readCZIWithBioFormats(fullfilename);
imageData=dip_image(imageData);
moreSeries=false;
if ~isscalar(imageData) % if more than one color, choose which one to open
    moreSeries=true;
    scrsz=get(0,'ScreenSize');
    dlgsz=[500 600];
    selectionFH=figure('Name','Select a channel','windowstyle','normal','toolbar','none','menubar','none','units','pixels','position',[(scrsz(3)-dlgsz(1))/2 (scrsz(4)-dlgsz(2))/2 dlgsz],'color',[0.9412 0.9412 0.9412],'NumberTitle','off','resize','off');
    uicontrol('parent',selectionFH,'style','text','units','pixels','position',[10 dlgsz(2)-40 dlgsz(1)-20 20],'fontsize',10,'foregroundcolor','red','fontweight','bold','string','More than one channel detected. Choose which one to open.');
    uicontrol('parent',selectionFH,'style','text','units','pixels','position',[dlgsz(1)/2-100 dlgsz(2)-70 100 20],'fontsize',10,'string','Image to show');
    numDims=numtensorel(imageData);
    popupH=uicontrol('parent',selectionFH,'style','popupmenu','units','pixels','position',[dlgsz(1)/2+10 dlgsz(2)-70 50 20],'fontsize',10,'string',cellfun(@(x) num2str(x),num2cell(1:numDims),'uniformoutput',false));
    imgDispSize=400;
    axisH=axes('parent',selectionFH,'units','pixels','position',[(dlgsz(1)-imgDispSize)/2 dlgsz(2)-90-imgDispSize imgDispSize imgDispSize]);
    if size(imageData{1},3)>1
        imshow(double(imageData{1}(:,:,0)),[]);
    else
        imshow(double(imageData{1}),[]);
    end
    buttonsz=[170 40];
    uicontrol('parent',selectionFH,'style','pushbutton','units','pixels','position',[(dlgsz(1)-buttonsz(1))/2 dlgsz(2)-90-imgDispSize-20-buttonsz(2) buttonsz],'fontsize',10,'string','Select the channel shown','callback',{@select_image_callback,popupH});
    set(popupH,'callback',{@select_image_popup_callback,axisH,imageData});
    selectionGuiData.channelSelected=1;
    guidata(selectionFH,selectionGuiData);
    uiwait(selectionFH);
    try
        selectionGuiData=guidata(selectionFH);
        close(selectionFH);
    catch
        eh=errordlg('The first channel will be selected.','Oops','modal');
        selectionGuiData.channelSelected=1;
        uiwait(eh);
    end
    imageData=imageData{selectionGuiData.channelSelected};
end
switch isempty(roiData)
    case true % no ROI data in image
        decision=assigninWithCheck(imageVarName,imageData);
        if ~isempty(roiVarName)
            eh=errordlg('I didn''t find any ROI information in the image, although you specified a ROI variable.','Oops','modal');
            uiwait(eh);
        end
    case false % there is ROI data in image
        if isempty(roiVarName)
            decision=assigninWithCheck(imageVarName,imageData);
            eh=errordlg('ROI information found, but no variable for ROIs given.','Oops','modal');
            uiwait(eh);
        else
            decision=assigninWithCheck({imageVarName,roiVarName},{imageData,roiData});
        end
end
if strcmp(decision,'Yes')
    fh=dipshow(imageData,'lin');
    dipmapping(fh,'global');
    reportText=['READ CZI IMAGE',newline,'File: ',filename,newline];
    if moreSeries
        reportText=[reportText,'Channel selected: ',num2str(selectionGuiData.channelSelected),newline];
    end
    reportText=[reportText,'Output variable for the images: ',imageVarName,newline,'Output variable for the ROI: ',roiVarName,newline];
    disp(reportText);
    displayTimedMessage('Images imported',lth,3,handleOfMain);
end
if ischar(fullfilename)
    guitempdata.imagefilepath=pathname;
    assignin('base','imagefilepath_frapfit',guitempdata.imagefilepath);
end
guidata(handleOfMain,guitempdata);
set(guitempdata.mainbuttonhandles,'enable','on');
set(editableH1,cellfun(@(x) 'enable',cell(numel(editableH1),1),'UniformOutput',false),enableStatus1');
set(editableH2,cellfun(@(x) 'enable',cell(numel(editableH2),1),'UniformOutput',false),enableStatus2');

function select_image_popup_callback(src,evt,axisH,imageData)
ih=get(axisH,'children');
delete(ih);
if size(imageData{get(src,'value')},3)>1
    imshow(double(imageData{get(src,'value')}(:,:,0)),[]);
else
    imshow(double(imageData{get(src,'value')}),[]);
end

function select_ROI_callback(src,evt,popupH)
gd=guidata(src);
gd.roiSelected=get(popupH,'value');
guidata(src,gd);
uiresume;

function select_image_callback(src,evt,popupH)
gd=guidata(src);
gd.channelSelected=get(popupH,'value');
guidata(src,gd);
uiresume;

function readImagesDoIt_callback(src,evt,varNameHandle,fileNameHandle,lth,handleOfMain)
changeMessagePermanently(lth,'Reading images...',handleOfMain);
drawnow;
guitempdata=guidata(handleOfMain);
varName=get(varNameHandle,'string');
fn=get(fileNameHandle,'string');
if isempty(varName)
    errordlg('Variable name is empty.','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
if isempty(fn)
    errordlg('File name is empty','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
[~,~,ext]=fileparts(fn);
try
    imagesRead=readtimeseries(fn,ext,[0 0],0,0);
catch
    errordlg('Error reading image series','Oops','modal');
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
    return;
end
decision=assigninWithCheck(varName,imagesRead);
if strcmp(decision,'Yes')
    fh=dipshow(imagesRead,'lin');
    dipmapping(fh,'global');
    reportText=['READ IMAGE SEQUENCE',newline,'File: ',fn,newline,'Output variable: ',varName,newline];
    disp(reportText);
    displayTimedMessage('Images imported',lth,3,handleOfMain);
else
    changeMessagePermanently(lth,'Nothing to do',handleOfMain);
end
if ischar(guitempdata.imagefilepath) && ~isempty(guitempdata.imagefilepath)
    assignin('base','imagefilepath_frapfit',guitempdata.imagefilepath);
end
guidata(handleOfMain,guitempdata);

function [imagehandle,axishandle]=getImageAndAxisHandleOfFigure(winnum)
children1=get(winnum,'Children');
flag=0;
i=1;
while flag==0 && i<=size(children1,1)
    if strcmp(get(children1(i),'Type'),'axes')
        flag=1;
    else
        i=i+1;
    end
end
axishandle=children1(i);
children2=get(children1(i),'Children');
flag=0;
i=1;
while flag==0 && i<size(children2,1)
    if strcmp(get(children2(i),'Type'),'image')
        flag=1;
    else
        i=i+1;
    end
end
imagehandle=children2(i);

function [filepath,filename]=getThisFileNameWithPath
filename=dbstack;
filename=filename.file;
fullpath=mfilename('fullpath');
filepath=fileparts(fullpath);

function help_callback(src,evt)
filepath=getThisFileNameWithPath;
web([filepath,filesep,'frapfit_help.html']);

function [editableH,enableStatus]=getEditableStuff(panelH)
hAll=get(panelH,'children');
counterBgh=0;
counterPh=0;
counterOther=0;
h=gobjects(size(hAll));
buttongroupH=gobjects(size(hAll));
panelH=gobjects(size(hAll));
for i=1:numel(hAll)
    htemp=hAll(i);
    htemp=whos('htemp');
    switch htemp.class
        case 'matlab.ui.container.ButtonGroup'
            counterBgh=counterBgh+1;
            buttongroupH(counterBgh)=hAll(i);
        case 'matlab.ui.container.Panel'
            counterPh=counterPh+1;
            panelH(counterPh)=hAll(i);
        otherwise
            counterOther=counterOther+1;
            h(counterOther)=hAll(i);
    end
end
h=h(1:counterOther);
buttongroupH=buttongroupH(1:counterBgh);
panelH=panelH(1:counterPh);
editableH=h(ismember(get(h,'style'),{'pushbutton','edit','radiobutton','popupmenu'}));
for i=1:numel(panelH)
    h2=get(panelH(i),'children');
    editableH2=h2(ismember(get(h2,'style'),{'pushbutton','edit','radiobutton','popupmenu'}));
    editableH=[editableH;editableH2];
end
for i=1:numel(buttongroupH)
    h2=get(buttongroupH(i),'children');
    editableH2=h2(ismember(get(h2,'style'),{'pushbutton','edit','radiobutton','popupmenu'}));
    editableH=[editableH;editableH2];
end
enableStatus=get(editableH,'enable');

function charNumber=formatNumberMyWay(number,signDig,maxLength)
if ~isnan(number)
    if number>1
        numberRound=round(number,signDig);
    else
        magnitude=floor(log10(abs(number)));
        numberRound=round(number,-magnitude+signDig);
    end
    if number>1e4
        charNumber=strjust(sprintf(['%',num2str(maxLength),'.',num2str(signDig),'e'],numberRound),'center');
    elseif numberRound>=1 && numberRound==round(numberRound,0)
        charNumber=num2str(number);
    elseif number>0.005
        charNumber=strjust(sprintf('%g',numberRound),'center');
    else
        charNumber=strjust(sprintf(['%',num2str(maxLength),'.',num2str(signDig),'d'],numberRound),'center');
    end
else
    charNumber=num2str(number);
end

function h=formattedText(textIn,fh)
posXY=textIn.position;
if isfield(textIn,'center')
    widthToCenter=textIn.center;
else
    widthToCenter=-1;
end
numOfSubtexts=numel(textIn.formatting);
h=zeros(numOfSubtexts,1);
posXYOrig=posXY;
shiftX=zeros(numOfSubtexts,1);
shiftY=zeros(numOfSubtexts,1);
for i=1:numOfSubtexts
    firstLastChar=textIn.formatting{i}{1};
    h(i)=uicontrol('parent',fh,'style','text','units','pixels','position',[posXY,10,10],'string',textIn.text(firstLastChar(1):firstLastChar(2)));
    j=2;
    while j<numel(textIn.formatting{i})
        formatType=textIn.formatting{i}{j};
        formatStyle=textIn.formatting{i}{j+1};
        switch formatType
            case 'style'
                switch formatStyle
                    case 'bold'
                        set(h(i),'fontweight','bold');
                    case 'italic'
                        set(h(i),'fontangle','italic');
                end
            case 'font'
                set(h(i),'fontname',formatStyle);
            case 'color'
                set(h(i),'foregroundcolor',formatStyle);
            case 'bgcolor'
                set(h(i),'backgroundcolor',formatStyle);
            case 'size'
                set(h(i),'fontsize',formatStyle);
            case 'shiftx'
                shiftX(i)=formatStyle;
            case 'shifty'
                shiftY(i)=formatStyle;
        end
        j=j+2;
    end
    wh=get(h(i),'extent');
    set(h(i),'position',[posXY(1)+shiftX(i) posXY(2)+shiftY(i) wh(3:4)]);
    posXY(1)=posXY(1)+wh(3)+shiftX(i);
end
if widthToCenter~=-1
    if posXY(1)<widthToCenter+posXYOrig(1)
        posXNew=posXYOrig(1)+(posXYOrig(1)+widthToCenter-posXY(1))/2;
        for i=1:numOfSubtexts
            posTemp=get(h(i),'position');
            set(h(i),'position',[posXNew,posTemp(2:4)]);
            if i<numOfSubtexts
                posXNew=posXNew+posTemp(3)+shiftX(i+1);
            else
                posXNew=posXNew+posTemp(3);
            end
        end
    end
end

function switchToActive_callback(src,evt,handleOfMain)
guiTempData=guidata(handleOfMain);
if isgraphics(guiTempData.activewindow)
    figure(guiTempData.activewindow);
end

function decision=assigninWithCheck(nameOfVariables,theVariables)
if ~iscell(nameOfVariables)
    tempName=cell(1);
    tempName{1}=nameOfVariables;
    nameOfVariables=tempName;
end
if ~iscell(theVariables)
    tempVar=cell(1);
    tempVar{1}=theVariables;
    theVariables=tempVar;
end
decision=checkVariableAndDecide(nameOfVariables);
if strcmp(decision,'Yes')
    for i=1:numel(nameOfVariables)
        assignin('base',nameOfVariables{i},theVariables{i});
    end
end

function decision=checkVariableAndDecide(nameOfVariables)
foundInBase=false(numel(nameOfVariables),1);
for i=1:numel(nameOfVariables)
    foundInBase(i)=evalin('base',['exist(''',nameOfVariables{i},''',''var'')==1']);
end
if sum(foundInBase(:))>0
    if sum(foundInBase(:))==1
        decision=questdlg(['Variable ',nameOfVariables{foundInBase},' already exists. Shall I overwrite it?'],'Overwrite?','Yes','No','Yes');
    else
        decision=questdlg(['Variables ',addCommaBetween(nameOfVariables(foundInBase)),' already exist. Shall I overwrite them?'],'Overwrite?','Yes','No','Yes');
    end
else
    decision='Yes';
end

function textWithComma=addCommaBetween(textsIn)
if iscolumn(textsIn)
    textsIn=textsIn';
end
textWithComma=cellfun(@(x) [x,', '],textsIn(1:numel(textsIn)-1),'uniformoutput',0);
textWithComma(end+1)=textsIn(end);
textWithComma=cell2mat(textWithComma);