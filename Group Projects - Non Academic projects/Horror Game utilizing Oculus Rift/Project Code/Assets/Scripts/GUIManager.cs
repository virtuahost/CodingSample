using UnityEngine;
using System.Collections;

public class GUIManager : MonoBehaviour {

	public GUITexture[] bars;
	
	private Rect[] barRects;
	private float[] measures;
	private SanitySetterScript sanityComp;
	private PlayerMovement staminaComp;
	// Use this for initialization
	void Start () {
	barRects = new Rect[bars.Length];
	measures = new float[bars.Length];
	for( int barCtr=0; barCtr<bars.Length ;barCtr++)
		{
			barRects[barCtr]=bars[barCtr].pixelInset;
		}
		
		sanityComp=GameObject.Find("sanitySetter").GetComponent<SanitySetterScript>();
		staminaComp=GameObject.Find("OVRPlayerController").GetComponent<PlayerMovement>();
		
	
	}
	
	// Update is called once per frame
	void Update () {
		measures[0]=sanityComp.sanity;
		measures[1]=staminaComp.stamina;
		for( int barCtr=0; barCtr<bars.Length ;barCtr++)
		{
			bars[barCtr].pixelInset=new Rect(barRects[barCtr].x, barRects[barCtr].y, (measures[barCtr]/100)*barRects[barCtr].width, barRects[barCtr].height);
		}
	}
}
