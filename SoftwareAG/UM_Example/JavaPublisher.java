/**
 * @author Lisa Scherf
 * Software AG, Darmstadt, Germany
 * 30.10.2019
 * 
 * Documentation: https://documentation.softwareag.com/onlinehelp/Rohan/num10-3/10-3_UM_webhelp/index.html#page/um-webhelp%2Fco-index_dg_17.html%23
 *
 * This example shows how to publish an event onto a Universal Messaging Channel.
 * When executed, an example heartbeat is send to the channel "HeartbeatChannel".
 * 
 */

import com.pcbsys.nirvana.client.*;
import org.json.*;

public class JavaPublisher {
	
	private static JavaPublisher mySelf = null;
	
	// Universal Messaging protocol, server adress and port
	static String um_server = System.getenv("umserver");
	static String[] RNAME={"nsp://" + um_server};
	// Name of the channel where the event should be published
	static String CHNAME="HeartbeatChannel";
	
	public static void main(String[] args) {
		
		// Create an instance for this class
	    mySelf = new JavaPublisher();
	    
	    // Example data
		String sourcename="hhi";
		String category="realtime";
	    
	    // Publish to the server & channel specified
	    mySelf.publish(RNAME, CHNAME, sourcename, category);
	}
	
	public void publish(String[] rname, String chname, String sourcename, String category) {
		
		// Get the timestamp
		Long ts = System.currentTimeMillis();
		
			nSessionAttributes nsa;
			try {
				
				// Connect to the Universal Messaging Server
				nsa = new nSessionAttributes(rname);
				nSession mySession=nSessionFactory.create(nsa);
				mySession.init();
				
				// Search and connect to a channel on the Universal Messaging Server
				//Create HeartbeatChannel
				nChannel myChannel;
			    try {
				nChannelAttributes cattrib = new nChannelAttributes(); 
				cattrib.setMaxEvents(0); 
				cattrib.setTTL(0); 
				cattrib.setType(nChannelAttributes.PERSISTENT_TYPE); 
				cattrib.setName(chname); 
				myChannel=mySession.createChannel(cattrib);
			    } catch(nChannelAlreadyExistsException e){
			    	nChannelAttributes chattr=new nChannelAttributes();
					chattr.setName(chname);
					myChannel=mySession.findChannel(chattr);
			    }
				
				// Create the JSONObject for the payload of the event with example data
				String jsonpayload = new JSONObject()
						.put("url", "https://hhiserver/realtime/stuttgart")
						.put("region-id", "Stuttgart")
						.put("component", "no2")
						.toString();
				
				// Set the properties for the event with example data
				nEventProperties props = new nEventProperties();			
				props.put("timestamp", ts);
				props.put("source",sourcename);
				props.put("category", category);
				// Create an event with a tag, event properties and the payload
				nConsumeEvent evt = new nConsumeEvent(props,jsonpayload.getBytes());
				// publish the event to the connected Channel
				myChannel.publish(evt);
				System.out.println("Event was published.");
				// Close the session we opened
			    try {
			      nSessionFactory.close(mySession);
			    } catch (Exception ex) {
			    }
			    // Close any other sessions within this JVM so that we can exit
			    nSessionFactory.shutdown();
				
				// Handle errors
			} catch (Exception e) {
			    e.printStackTrace();
			    System.exit(1);
			}
	}
}
