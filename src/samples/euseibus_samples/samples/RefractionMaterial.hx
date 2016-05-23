package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.procedurals.standard.MarbleProceduralTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RefractionMaterial {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", 0, 0, 10, Vector3.Zero(), scene);		
		camera.setPosition(new Vector3(0, 5, -10));
		camera.attachControl();
		
		camera.upperBetaLimit = Math.PI / 2;
		camera.lowerRadiusLimit = 4;
		
		var light = new HemisphericLight("light1", new Vector3(1, 1, 0), scene);
		light.intensity = 0.7;
		
		var knot = Mesh.CreateTorusKnot("knot", 1, 0.4, 128, 64, 2, 3, scene);
		
		var lupa = Mesh.CreateBox("lupa", 2, scene);
		lupa.position.y = 3;
		lupa.scaling.y = 1.05;
		
		var yellowSphere = Mesh.CreateSphere("yellowSphere", 16, 1.5, scene);
		yellowSphere.setPivotMatrix(Matrix.Translation(3, 0, 0));
		var yellowMaterial = new StandardMaterial("yellowMaterial", scene);
		yellowMaterial.diffuseColor = Color3.Yellow();
		yellowSphere.material = yellowMaterial;
		
		var greenSphere = Mesh.CreateSphere("greenSphere", 16, 1.5, scene);
		greenSphere.setPivotMatrix(Matrix.Translation(0, 0, 3));
		var greenMaterial = new StandardMaterial("greenMaterial", scene);
		greenMaterial.diffuseColor = Color3.Green();
		greenSphere.material = greenMaterial;
		
		// Ground
		var ground = Mesh.CreateBox("Mirror", 1.0, scene);
		ground.scaling = new Vector3(30, 0.01, 30);
		ground.material = new StandardMaterial("ground", scene);
		var marbleTexture = new MarbleProceduralTexture("marble", 1024, scene);
		marbleTexture.numberOfTilesHeight = 5;
		marbleTexture.numberOfTilesWidth = 5;
		cast(ground.material, StandardMaterial).ambientTexture = marbleTexture;
		ground.position = new Vector3(0, -2, 0);
		
		// Main material 
		var mainMaterial = new StandardMaterial("main", scene);
		knot.material = mainMaterial;
		lupa.material = mainMaterial;
		
		var probe = new ReflectionProbe("rprobe", 512, scene);
		probe.renderList.push(yellowSphere);
		probe.renderList.push(greenSphere);
		probe.renderList.push(ground);
		mainMaterial.diffuseColor = new Color3(1, 0.5, 0.5);
		mainMaterial.refractionTexture = probe.cubeTexture;
		mainMaterial.refractionFresnelParameters = new FresnelParameters();
		mainMaterial.refractionFresnelParameters.bias = 0.2;
		mainMaterial.refractionFresnelParameters.power = 4;
		mainMaterial.refractionFresnelParameters.leftColor = Color3.Black();
		mainMaterial.refractionFresnelParameters.rightColor = Color3.White();
		mainMaterial.refractionFresnelParameters.isEnabled = false;
		mainMaterial.indexOfRefraction = 1.05;
		mainMaterial.bumpTexture = new Texture("assets/img/normalMap.jpg", scene);
		
		// Fog
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogColor = scene.clearColor;
		scene.fogStart = 20.0;
		scene.fogEnd = 50.0;
		
		// Animations
		scene.registerBeforeRender(function() {
			yellowSphere.rotation.y += 0.01;
			greenSphere.rotation.y += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}