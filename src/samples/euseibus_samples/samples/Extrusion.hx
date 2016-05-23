
package samples;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.polygonmesh.Polygon;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder.PolyhedronOptions;
import com.babylonhx.math.Space;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Extrusion {

	public function CreateTri(name:String, points:Array<Float>, color:Color4, scene:Scene):Mesh{
		var poly = new Mesh(name,scene);

		var indices:Array<Int> = [0,1,2];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [0,0,1,0,0.5,1];
		var colors:Array<Float> = [];

		VertexData.ComputeNormals(points,indices,normals);
		VertexData._ComputeSides(Mesh.DEFAULTSIDE,points,indices,normals,uvs);
		var tri_vertexData = new VertexData();

		tri_vertexData.positions = points;
		tri_vertexData.indices = indices;
		tri_vertexData.normals = normals;
		tri_vertexData.uvs = uvs;
		tri_vertexData.colors = [color.r,color.g,color.b,color.a,color.r,color.g,color.b,color.a,color.r,color.g,color.b,color.a];

		tri_vertexData.applyToMesh(poly,true);

		poly.isPickable=true;
		poly.edgesColor=new Color4(1.0,0.0,0.0,1.0);
		poly.enableEdgesRendering();
		//poly.edgesWidth=10.0;
		return poly;
	}


	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, 0.8, 80, Vector3.Zero(), scene);
		camera.allowUpsideDown=true;
		camera.attachControl(this, true);

		scene.ambientColor=Color3.FromInt(0xffffff);

		var light = new HemisphericLight("light1", new Vector3(0, 20, 0), scene);
		light.diffuse = Color3.FromInt(0xffffff);

		var light2 = new HemisphericLight("light2", new Vector3(0, -20, 0), scene);
		light2.diffuse = Color3.FromInt(0xffffff);


		var mat = new StandardMaterial("mat", scene);
		mat.diffuseColor=new Color3(0.6,0.6,0.8);
		mat.alpha=0.25;
				
		//var lathe = createLathe(shape, 1, 40);

		//var trunk = Mesh.CreateCylinder("Trunk",20,2,8,5,2,scene,true);
		//trunk.translate(new Vector3(0, 1, 0), -4, Space.LOCAL);
		//trunk.material = mat;
		//trunk.material.backFaceCulling = false;

		var leavesOptions:PolyhedronOptions = {
			type:2,
			size:6.0,
			updatable:true
		};
		var leaves = Mesh.CreatePolyhedron("Leaves",leavesOptions,scene);
		leaves.material=mat;
		leaves.material.backFaceCulling=true;
		leaves.isPickable=true;
		//leaves.enableEdgesRendering();
		leaves.edgesColor=new Color4(0.4,0.5,0.9,1.0);
		leaves.edgesWidth=5.0;




		scene.onPointerDown = function (x:Float, y:Float, button:Int, pickResult:PickingInfo) {
			// if the click hits the ground object, we change the impact position
			if (pickResult.hit) {
				var obj = cast(pickResult.pickedMesh,Mesh);
				//pickResult.

				trace(obj.name);
				if(obj.name=="highlight"){
					trace("Dehighlighting triangle");
					obj.dispose();

				}else{

				var f=pickResult.faceId;
				var face=obj.getIndices().slice(3*f,3*f+3);
				var tri_points:Array<Float> = [];
				for (i in 0...3){
					for (j in 0...3){
						tri_points.push(obj.getVerticesData("position")[face[i]*3+j]);
				    }
				}
				trace(tri_points);

				var tri=CreateTri("highlight",tri_points,
				                            Color4.FromHexString("#aaddaaff"),scene);
					//tri.material.backFaceCulling=false;

				tri.translate(new Vector3(tri.geometry.getVerticesData("normal")[0],
							  			  tri.geometry.getVerticesData("normal")[1],
							  			  tri.geometry.getVerticesData("normal")[2]),0.3);
				}
			}
		};

		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
		
}
