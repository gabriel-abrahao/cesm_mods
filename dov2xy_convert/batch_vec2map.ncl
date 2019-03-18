load "~/lib_abrahao.ncl"
begin
inpfolder		=	"../ref_inputs/"

;infname			=	"mytest_I_2000.clm2.h1.0001-01-01-00000.nc"
vname			=	"TLAI"

outfolder		=	"../output/"

infnames = systemfunc("ls " + inpfolder)
print(infnames)

do count = 0,dimsizes(infnames)-1

	infname			=	infnames(count)
	outfname		=	"4d_" + infname	
	
	inpfpath		=	inpfolder + infname
	outfpath		=	outfolder + outfname
	
	arqin = addfile(inpfpath,"r")
	
	system("rm " + outfpath)
	arqout = addfile(outfpath,"c")
	
	varin = arqin->$vname$
	printVarSummary(varin)
	
	lon = arqin->lon
	lat = arqin->lat
	time = arqin->time
	ixy = arqin->pfts1d_ixy
	jxy = arqin->pfts1d_jxy
	type = arqin->pfts1d_itype_veg
	
	nrec = dimsizes(ixy)
	
	printVarSummary(ixy)
	
	;print(jxy(0:200))
	minpft = (min(type))
	maxpft = (max(type))
	npft = maxpft - minpft + 1
	pft = ispan(minpft,maxpft,1)
	
	nlat = dimsizes(lat)
	nlon = dimsizes(lon)
	ntim = dimsizes(time)
	
	varout = new((/ntim,npft,nlat,nlon/),typeof(varin))
	varout!0 = "time"
	varout!1 = "pft"
	varout!2 = "lat"
	varout!3 = "lon"
	varout&pft = pft
	varout&time = time
	varout&lat = lat
	varout&lon = lon
	
	
	printVarSummary(varout)
	
	
	do t = 0,ntim-1
		print("Running time " + (t+1) + " of " + ntim)
		do i = 0,nrec-1
			;print(""+(100*(i+1)/nrec))
			;print(ixy(i))
			varout(t,type(i),jxy(i)-1,ixy(i)-1) = (/varin(t,i)/)
		end do
	end do
	
	arqout->$vname$ = varout
	arqout->time_bounds = arqin->time_bounds

end do

end
