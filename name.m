matRad_rc
load TG119.mat

pln.propStf.isoCenter       = matRad_getIsoCenter(cst,ct,0);
pln.propStf.bixelWidth      = 5; 
pln.propStf.numOfVoxels = prod(ct.cubeDim);
pln.voxelDimensions = ct.cubeDim;
pln.radiationMode = 'protons';
pln.propOpt.bioOptimization = 'none';
pln.numOfFractions = 30;
pln.propOpt.runSequencing = false;
pln.propOpt.runDAO = false;
pln.machine = 'Generic';
display(pln);

display(cst{1,6});
ixOAR = 1;
ixPTV = 2;
cst{ixOAR,1} = 0;
cst{ixOAR,2} = 'contour';
cst{ixOAR,3} = 'OAR';

cst{ixPTV,1} = 1;
cst{ixPTV,2} = 'target';
cst{ixPTV,3} = 'TARGET';

%cst{ixPTV,6}{1} = struct(DoseConstraints.matRad_MinMaxDose(0,2,1));


myGantryAngles;
disp(myGantryAngles);

for i = 1:numel(myGantryAngles)
    global myGantryAngles;
    currPlan = pln;

    currPlan.propStf.gantryAngles = myGantryAngles(i);
    currPlan.propStf.couchAngles = 0;
    currPlan.propStf.numOfBeams = 1;

    stf = matRad_generateStf(ct, cst, currPlan);
    dij = matRad_calcParticleDose(ct,stf, currPlan, cst);
    stf2 = struct(stf);
    dij2=struct(dij);
   
    resContainer(i) = struct(matRad_fluenceOptimization(dij, cst, currPlan));
    [dvh,qi] = matRad_indicatorWrapper(cst,pln,resContainer);
    
    dvh2 = struct(dvh);
    qi2 = struct(qi);
    

    save('stf.mat','stf2');
    save('dvh.mat','dvh2');
    save('qi.mat','qi2');
    save('dij5.mat','dij2');
    
    
plane      = 3;
slice      = round(pln.propStf.isoCenter(1,3)./ct.resolution.z);
doseWindow = [0 max([resContainer(1).physicalDose(:)])];    
    
    
end

figure,title('phantom plan')
matRad_plotSliceWrapper(gca,ct,cst,1,resContainer(1).physicalDose,plane,slice,[],[],colorcube,[],doseWindow,[]);

figure;image=imagesc(resContainer(1).physicalDose(:,:,45));
saveas(image,'image1.png');

