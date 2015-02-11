using UnityEngine;
using System.Collections;

public class BoxFlipper : MonoBehaviour {
	public enum BoxGravityState{
		Roof,
		Floor
	}
	public BoxGravityState _gravityState;
    public LayerMask _layerMaskFloor;
    public LayerMask _layerMaskRoof;
	public float boxJumpSpeed = 3.5f;
	public bool hitState = false;
	public float pushForce = 0.005f;
//	public GameObject  bullet;
	// Use this for initialization
	void Start () {
		if (this.gameObject.layer == LayerMask.NameToLayer ("Roof")) {
			_gravityState = BoxGravityState.Roof;
		} else {
			_gravityState = BoxGravityState.Floor;
		}
	}
	
	// Update is called once per frame
	void Update () {
		if (hitState) {		
            float finalPositionY = 0f;
			Vector3 moveVector = transform.position;
            //Gravity flip floor and roof detector for variable height puzzle start
            RaycastHit hitUp;
            float scaleY = (transform.position.normalized.y + 1000) * (_gravityState == BoxGravityState.Roof ? -1 : 1);
            Debug.Log(scaleY);
            Vector3 lnCastVector = new Vector3(transform.position.x,scaleY, transform.position.z);
            if (Physics.Linecast(transform.position,lnCastVector,out hitUp,(_gravityState == BoxGravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
                finalPositionY = hitUp.point.y;
            }
            //Gravity flip floor and roof detector for variable height puzzle end
			if(_gravityState == BoxGravityState.Floor)
			{
				Vector3 finalPosition = new Vector3(moveVector.x, finalPositionY, moveVector.z);
				transform.position = Vector3.MoveTowards(moveVector, finalPosition, boxJumpSpeed * Time.deltaTime);
				if(transform.position == finalPosition){
					_gravityState = BoxGravityState.Roof;
					this.gameObject.layer = LayerMask.NameToLayer("Roof");
					hitState = false;
				}
			}
			else if(_gravityState == BoxGravityState.Roof)
			{
                Vector3 finalPosition = new Vector3(moveVector.x, finalPositionY, moveVector.z);
				transform.position = Vector3.MoveTowards(moveVector, finalPosition, boxJumpSpeed * Time.deltaTime);
				if(transform.position == finalPosition){
					_gravityState = BoxGravityState.Floor;
					this.gameObject.layer = LayerMask.NameToLayer("Floor");
					hitState = false;
				}
			}
		}
	}
	
	void OnTriggerEnter(Collider colldBox)
	{
		if (colldBox.tag == "Projectile") {
						hitState = true;
		}
	}

	void OnTriggerStay(Collider colldBox)
	{
		if (colldBox.tag == "Player") {
			Vector3 pushVector = (this.transform.position - colldBox.gameObject.transform.position)* -1 * pushForce;
			colldBox.gameObject.GetComponent<CharacterController>().Move(pushVector.normalized);
		}
		
	}
}
