using UnityEngine;
using System.Collections;

public class LockedDoorBehaviour : MonoBehaviour {

	public GameObject doorAnimator;
	public GameObject player;
	public int pickUpId;
	public bool locked=true;
	
	void OnTriggerEnter(Collider c)
	{
		Animator animator=doorAnimator.GetComponent<Animator>();
		Inventory inv=player.GetComponent<Inventory>();
		
		if(c.gameObject.tag=="player")
		{
			Vector3 playerDirection=transform.position-c.transform.position;
			float crossY=Vector3.Cross(playerDirection, transform.forward).y;
			if(crossY > 0 )
			{
				if(locked)
				{
					if(inv.hasItem(pickUpId))
					{
						animator.SetBool("openClock", true);
					}else{
						animator.SetBool("openLocked", true);
						if(!doorAnimator.GetComponent<AudioSource>().isPlaying){
							doorAnimator.GetComponent<AudioSource>().Play();
						}
					}
				}
				else
				{
					animator.SetBool("openClock", true);
				}
			}else{
				if(locked)
				{
					if(inv.hasItem(pickUpId))
					{
						animator.SetBool("openAntiClock", true);
					}else{
						animator.SetBool("openLocked", true);
						if(!doorAnimator.GetComponent<AudioSource>().isPlaying){
							doorAnimator.GetComponent<AudioSource>().Play();
						}
					}
				}
				else
				{
					animator.SetBool("openAntiClock", true);
				}
			}
		}
	}
	
	void OnTriggerExit(Collider c)
	{
		Animator animator=doorAnimator.GetComponent<Animator>();
		Inventory inv=player.GetComponent<Inventory>();
		if(c.gameObject.tag=="player")
		{
			Vector3 playerDirection=transform.position-c.transform.position;
			float crossY=Vector3.Cross(playerDirection, transform.forward).y;
			Debug.Log(Vector3.Cross(playerDirection, transform.forward));
			if(crossY > 0 )
			{
				if(locked)
				{
					if(inv.hasItem(pickUpId))
					{
						animator.SetBool("closeAntiClock", true);
					}
				}
				else
				{
					animator.SetBool("closeAntiClock", true);
				}
			}else{
				if(locked)
				{
					if(inv.hasItem(pickUpId))
					{
						animator.SetBool("closeClock", true);
					}
				}
				else
				{
					animator.SetBool("closeClock", true);
				}
			}
		}
	}
}
