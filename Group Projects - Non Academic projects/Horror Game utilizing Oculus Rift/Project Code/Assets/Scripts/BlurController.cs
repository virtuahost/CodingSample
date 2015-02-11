using UnityEngine;
using System.Collections;

public class BlurController : MonoBehaviour {
	
	public float sanity;
	public float sanityThreshold;
	public float blurRate;
	public float baseBlurTime;
	public float currBlurTime;
	public GameObject heartBeat;
	public AnimationCurve blurCurve;
	public GUITexture screenBlur;
	
	private float finalBlur;
	private Blur blur;
	private bool blurUp = true;
	private float lastBlurTime;
	private AudioSource heartBeatSound;
	private Color texColor;
	
	private bool isRunning;
	
	// Use this for initialization
	void Start () {
		blur=gameObject.GetComponent<Blur>();
		lastBlurTime = Time.time;
		heartBeatSound = heartBeat.GetComponent<AudioSource>();
		texColor=screenBlur.color;
	}
	
	// Update is called once per frame
	void LateUpdate () {

		if(sanity < sanityThreshold)
		{
			currBlurTime = baseBlurTime * sanity;
			if(Time.time - lastBlurTime > currBlurTime)
			{	
				if(!isRunning)
					oneShotPulse();
				lastBlurTime=Time.time;
			}
		}
	
	}
	
	IEnumerator blurPulse()
	{
		isRunning=true;
		if(!heartBeatSound.isPlaying)
			heartBeatSound.Play();
		for(float t=0 ; t<1.0 ; t+=blurRate*Time.deltaTime){
			screenBlur.color = new Color(128, 128, 128, blurCurve.Evaluate(t)*3);
			blur.blurSize = blurCurve.Evaluate(t)*20;
			yield return new WaitForSeconds(0.01f);
		}
		isRunning=false;
	}
	
	public void oneShotPulse()
	{
		StartCoroutine("blurPulse");
	}
}
