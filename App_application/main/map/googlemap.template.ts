
const template: Template = {
	properties: {
		'TRoot.$MapUrl'() {
			//return 'https://www.google.com/maps/embed/v1/place?key=@{AppSettings.GoogleMapsApiKey}&q=Eiffel+Tower,Paris+France&language=uk&region=UA';
			return 'https://www.google.com/maps/embed/v1/place?key=@{AppSettings.GoogleMapsApiKey}&q=Downing+street+10,London+England&language=uk&region=UA';
		},
	}
} 

export default template;