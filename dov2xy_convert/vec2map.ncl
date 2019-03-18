load "~/lib_abrahao.ncl"
begin

infname			=	"../ref_inputs/mytest_I_2000.clm2.h1.0001-01-01-00000.nc"
vname			=	"TLAI"


arqin = addfile(infname,"r")

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

varout = new((/npft,ntim,nlat,nlon/),typeof(varin))
varout!0 = "pft"
varout!1 = "time"
varout!2 = "lat"
varout!3 = "lon"
varout&pft = pft
varout&time = time
varout&lat = lat
varout&lon = lon


printVarSummary(varout)



t = 0
do i = 0,nrec-1
	;print(""+i)
	;print(ixy(i))
	varout(type(i),t,jxy(i)-1,ixy(i)-1) = varin(t,i)
end do

dum_write(varout,"varout")


end
