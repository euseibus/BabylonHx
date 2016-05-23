package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Node;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.layer.Layer;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class InstancedBones {

	public function new(scene:Scene) {
		var light = new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
		var camera = new ArcRotateCamera("Camera", 0, 0, 20, new Vector3(0, 30, 0), scene);
		camera.attachControl(this);
		camera.setPosition(new Vector3(20, 70, 120));
		light.position = new Vector3(50, 250, 200);
		light.shadowOrthoScale = 2.0;
		camera.minZ = 1.0;
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
		
		scene.ambientColor = new Color3(0.3, 0.3, 0.3);
		
		// Ground
		var ground = Mesh.CreateGround("ground", 700, 700, 1, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseColor = new Color3(0.2, 0.2, 0.2);
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.material = groundMaterial;
		ground.receiveShadows = true;
		
		// Shadows
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.usePoissonSampling = true;
		
		// Dude
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.ImportMesh("him", "assets/models/Dude/", "Dude.babylon", scene, function (newMeshes2:Array<AbstractMesh>, particleSystems2:Array<ParticleSystem>, skeletons2:Array<Skeleton>) {
			var dude = newMeshes2[0];
			
			for (index in 1...newMeshes2.length) {
				shadowGenerator.getShadowMap().renderList.push(newMeshes2[index]);
			}
			
			for (count in 0...10) {
				var offsetX = 200 * Math.random() - 100;
				var offsetZ = 200 * Math.random() - 100;
				for (index in 1...newMeshes2.length) {
					var instance:InstancedMesh = cast(newMeshes2[index], Mesh).createInstance("instance" + count);
					
					instance.parent = newMeshes2[index].parent;
					instance.position = newMeshes2[index].position.clone();					
					
					if (cast(instance.parent, Mesh).subMeshes == null) {
						instance.position.x += offsetX;
						instance.position.z -= offsetZ;
					}
				}
			}
			
			dude.rotation.y = Math.PI;
			dude.position = new Vector3(0, 0, -80);
			
			scene.beginAnimation(skeletons2[0], 0, 100, true, 1.0);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
