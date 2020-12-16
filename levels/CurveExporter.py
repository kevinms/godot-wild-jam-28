import bpy
import os

def tocsv(v):
    return '{},{},{}'.format(v.x,v.y,v.z)

def main():
    myCurve = bpy.data.curves[0] # here your curve
    spline= myCurve.splines[0] # maybe you need a loop if more than 1 spline

    # May need to apply world transform to points before exporting
    #obj = bpy.data.objects['Wall']
    #mat = obj.matrix_world
    
    outpath = bpy.path.basename(bpy.data.filepath)
    outpath = "//" + os.path.splitext(outpath)[0] + ".csv"

    with open(bpy.path.abspath(outpath), 'w') as out:
        for x in range(len(spline.bezier_points)):
            p = spline.bezier_points[x]
            print('{},{},{},{}'.format(
                tocsv(p.co),
                tocsv(p.handle_left - p.co),
                tocsv(p.handle_right - p.co),
                p.tilt),
                file = out)

if __name__ == "__main__":
    main()