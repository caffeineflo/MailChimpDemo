# MailChimp Cimperator

This demo has been written for the programming task in the MailChimp application process by Florian Harr.

The task was to create a small app (assumed it's supposed to be an app, even though not specifically mentioned) that shows lists and it's members for a given API key. 
Languages to do this in are Objective-C, Swift or Java with Objective-C being the preferred option. 

The MailChimp API in version 3.0 has HATEOAS capabilities with provides schemas. In an ideal world, these schemas would be parsed and the app would adjust to that so that the coupling between the API and the client would be less tight. To demonstrate my understanding of this connection, I implemented partially the HATEOAS "_links" array to not rely on statically typed links but left out the schemas as that would be too time consuming for a small demo like this.

The UI is rudimentary as this demo is a coding exercise and not a design exercise. Therefore I dropped the storyboard, went with a NavigationController + TableViewController and a NIB for the detail view. For anything larger than that, I'd rather go with a storyboard.

NSLog calls and any other debug things have been removed from this project. I recommend though to use Paw for API debugging and MailChimps excellent [playgrounds](https://us14.api.mailchimp.com/playground/).