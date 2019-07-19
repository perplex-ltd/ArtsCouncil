
if (typeof XRM == "undefined" || !XRM) {
	var XRM = {};
}

XRM.namespace = function() {
	var a = arguments, o = null, i, j, d;
	for (i = 0; i < a.length; i = i + 1) {
		d = ("" + a[i]).split(".");
		o = XRM;

		// XRM is implied, so it is ignored if it is included.
		for (j = (d[0] == "XRM") ? 1 : 0; j < d.length; j = j + 1) {
			o[d[j]] = o[d[j]] || {};
			o = o[d[j]];
		}
	}

	return o;
};

XRM.log = function(msg, cat, src) {
	try {
		if ((typeof(YAHOO) != 'undefined') && YAHOO && YAHOO.widget && YAHOO.widget.Logger && YAHOO.widget.Logger.log) {
			return YAHOO.widget.Logger.log(msg, cat, src);
		}
		
		if ((typeof(console) == 'undefined') || !console) {
			return false;
		}
		
		var source = src ? ('[' + src + ']') : '';
		
		if (cat == 'warn' && console.warn) {
			console.warn(msg, source);
		}
		else if (cat == 'error' && console.error) {
			console.error(msg, source);
		}
		else if (cat == 'info' && console.info) {
			console.info(msg, source);
		}
		else if (console.log) {
			console.log(msg, source);
		}
		
		return true;
	}
	catch (e) {
		return false;
	}
};

(function() {

	var activations = [];
	var activated = false;

	XRM.onActivate = function(fn) {
		if (activated) {
			fn();
		}
		else {
			activations.push(fn);
		}
	}

	XRM.activate = function(jquery) {
		XRM.jQuery = jquery;
		
		for (var i = 0; i < activations.length; i++) {
			activations[i]();
		}
		
		activated = true;
	}

})();

XRM.onActivate(function() {

	var ns = XRM.namespace('util');
	var $ = XRM.jQuery;
	
	ns.expandUriTemplate = function(uriTemplate, data) {
		return uriTemplate.replace(/{([^}]+)}/g, function(match, capture) {
			return data[capture];
		});
	}
	
	ns.formatDateForDataService = function(date) {
		// Maybe add some better logic here later, but Astoria doesn't like the result
		// of IE's toUTCString, while it does for other browsers. Turns out the only
		// difference is that IE puts 'UTC' for the timezone, while the others put 'GMT'.
		// Hack to fix the IE value.
		return date.toUTCString().replace(/UTC/, 'GMT');
	}
	
	var uriParser = {
		pattern: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
		key: ["source", "protocol", "authority", "userInfo", "user", "password", "host", "port", "relative", "path", "directory", "file", "query", "anchor"]
	}
	
	ns.parseUri = function(str) {
		var matches = uriParser.pattern.exec(str),
		    key = uriParser.key,
		    uri = {},
		    i = key.length;
		
		while (i--) uri[key[i]] = matches[i] || "";
		
		return uri;
	}
	
	ns.isSameDomain = function(location, url) {
		var parsedUri = ns.parseUri(url);
		
		return parsedUri.host == '' || parsedUri.host == location.host;
	}
	
	// Transforms a string value into a similar string usable as a URL slug/partial URL path.
	ns.slugify = function(value) {
		return value.
			replace(/^\s+/, ''). // Strip leading whitespace.
			replace(/\s+$/, ''). // Strip trailing whitespace.
			toLowerCase().
			replace(/[^-a-z0-9~\s\.:;+=_\/]/g, ''). // Strip chars that are not alphanumeric, or within a certain set of allowed punctuation.
			replace(/[\s:;=+]+/g, '-'). // Replace whitespace and certain punctuation with a hyphen.
			replace(/[\.]+/g, '.'); // Replace runs of multiple periods with a single period.
	}
	
	$.fn.extend({
		syncSlugify: function(source) {
			var slugify = XRM.util.slugify;
			source = $(source);
			var target = this;
			var oldValue = source.val();
			source.keyup(function() {
				var currentValue = source.val();
				if (slugify(oldValue) == target.val()) {
					target.val(slugify(currentValue));
				}
				oldValue = currentValue;
			});
		}
	});
	
	XRM.localizations = {
		'entity.create.label': 'New',
		'entity.create.adx_webfile.label': 'Child file',
		'entity.create.adx_webfile.tooltip': 'Create a new child file',
		'entity.create.adx_weblink.tooltip': 'Add a new link',
		'entity.create.adx_webpage.label': 'Child page',
		'entity.create.adx_webpage.tooltip': 'Create a new child page',
		'entity.delete.adx_weblink.tooltip': 'Delete this item',
		'entity.update.label': 'Edit',
		'adx_webfile.shortname': 'file',
		'adx_webfile.update.tooltip': 'Edit this file',
		'adx_weblink.update.tooltip': 'Edit this link',
		'adx_webpage.shortname': 'page',
		'adx_webpage.update.tooltip': 'Edit this page',
		'datetimepicker.datepicker.label': 'Choose a Date',
		'editable.cancel.label': 'Cancel',
		'editable.delete.label': 'Delete',
		'editable.delete.tooltip.prefix': 'Delete this ',
		'editable.label': 'Edit',
		'editable.label.prefix': 'Edit ',
		'editable.loading': 'Loading...',
		'editable.required.label': '(required)',
		'editable.save.label': 'Save',
		'editable.saving': 'Saving...',
		'editable.sortable.tooltip': 'Move this item',
		'editable.tooltip': 'Edit this content',
		'error.dataservice.default': 'An error has occured while saving your content. Your changes have not been saved.',
		'error.dataservice.loading': 'An error has occured while loading content required for this feature.',
		'error.dataservice.loading.field.prefix': 'Unable to load ',
		'confirm.delete.entity.prefix': 'Are you sure you want to delete this ',
		'confirm.no': 'No',
		'confirm.unsavedchanges': "You have unsaved changes. Proceed?",
		'confirm.yes': 'Yes',
		'validation.required.suffix': ' is a required field.',
		'sitemapchildren.header.label': 'Edit children'
	};

	XRM.localize = function(key) {
		return XRM.localizations[key];
	}

	XRM.yuiSkinClass = 'yui-skin-sam';
	XRM.zindex = 4;

	XRM.tinymceSettings = {
		theme: 'advanced',
		plugins: 'style,safari,advimage,inlinepopups,table,contextmenu,paste,media,searchreplace,directionality,fullscreen',
		mode: 'none',
		height: '340',
		theme_advanced_resizing: true,
		theme_advanced_resize_horizontal: false,
		theme_advanced_resizing_use_cookie: false,
		theme_advanced_statusbar_location: "bottom",
		theme_advanced_toolbar_location: "top",
		theme_advanced_toolbar_align: "left",
		theme_advanced_buttons1: "save,cancel,fullscreen,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,ltr,rtl,|,styleprops,formatselect,help",
		theme_advanced_buttons2: "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,media,cleanup,code",
		theme_advanced_buttons3_add_before: "tablecontrols,separator",
		width: "100%",
		convert_urls: false,
		forced_root_block: 'p',
		invalid_elements: "html,head,meta,title,body",
		remove_linebreaks: false,
		apply_source_formatting: true
	};

	XRM.tinymceCompactSettings = $.extend(true, {}, XRM.tinymceSettings);
	XRM.tinymceCompactSettings.height = null;
	XRM.tinymceCompactSettings.theme_advanced_toolbar_location = "external";
	XRM.tinymceCompactSettings.theme_advanced_statusbar_location = "none";

	XRM.namespace('editable').editableClassRegexp = /xrm-editable-(\S+)/i;
	
});

XRM.onActivate(function() {
	
	var ns = XRM.namespace('data');
	var $ = XRM.jQuery;
	var dataServicesNS = XRM.namespace('data.services');
	var JSON = YAHOO.lang.JSON;
	
	var acceptHeader = 'application/json, text/javascript';
	
	function createJSONResponseHandler(handler) {
		return function(data, textStatus, xhr) {
			if (!data) {
				handler(null, textStatus, xhr);
				return;
			}
			
			// Get the data as raw text to bypass jQuery 1.4 stricter JSON parsing. WCF Data Services
			// returns invalid JSON pretty regularly. This eval technique is not ideal, obviously, but
			// it's analogous to what jQuery 1.3 did.
			try {
				var evaled = eval("(" + data + ")");
				handler(JSON.parse(JSON.stringify(evaled)), textStatus, xhr);
			}
			catch (e) {
				XRM.log('Error parsing response JSON: ' + e, 'error');
				handler(null, textStatus, xhr);						
			}
		}
	}
	
	ns.getReponseHandler = function(handler) {
		return {
			dataType: 'text',
			handler: $.isFunction(handler) ? createJSONResponseHandler(handler) : null
		}
	}
	
	ns.getJSON = function(uri, options) {
		options = options || {};
		var responseHandler = ns.getReponseHandler(options.success);
		$.ajax({
			beforeSend: function(xhr) {
				xhr.setRequestHeader('Accept', acceptHeader);
			},
			url: uri,
			type: 'GET',
			processData: true,
			dataType: responseHandler.dataType,
			contentType: 'application/json',
			success: function(data, textStatus, jqXHR) {
			    validateLoginSession(data, textStatus, jqXHR, responseHandler.handler);
			},
			error: options.error
		});
	}

	ns.postJSON = function(uri, data, options) {
		options = options || {};
		var responseHandler = ns.getReponseHandler(options.success);
		$.ajax({
			beforeSend: function(xhr) {
				xhr.setRequestHeader('Accept', acceptHeader);

				if (options.httpMethodOverride) {
					xhr.setRequestHeader('X-HTTP-Method', options.httpMethodOverride);
				}
			},
			url: uri,
			type: 'POST',
			processData: options.processData || false,
			dataType: responseHandler.dataType,
			contentType: 'application/json',
			data: data ? JSON.stringify(data) : null,
			success: function(data, textStatus, jqXHR) {
			    validateLoginSession(data, textStatus, jqXHR, responseHandler.handler);
			},
			error: options.error
		});
	}

	// Given an ADO.NET Data Service entity URI, an attribute name, and an attribute value,
	// update that attribute on the entity.
	dataServicesNS.putAttribute = function(uri, name, value, options) {
		options = options || {};
		options.httpMethodOverride = 'MERGE';
		var data = {};
		data[name] = value;
		ns.postJSON(uri, data, options);
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('ui');
	var yuiSkinClass = XRM.yuiSkinClass;
	var overlayManager = new YAHOO.widget.OverlayManager();
	var JSON = YAHOO.lang.JSON;
	var $ = XRM.jQuery;
	
	ns.registerOverlay = function(overlay) {
		overlayManager.register(overlay);
	}
	
	ns.showProgressPanel = function(message, options) {
		// Create a root container so we can apply our YUI skin class.
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);

		// Create the actual container element for the panel, with our desired classes.
		var panelContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-wait').appendTo(yuiContainer);

		var panel = new YAHOO.widget.Panel(panelContainer.get(0), options);

		panel.setHeader(message);
		panel.setBody(' ');
		panel.render();
		panel.show();

		ns.registerOverlay(panel);
		panel.focus();

		// Return a funtion that will cleanup/remove the panel.
		return function() {
			panel.hide();
			yuiContainer.remove();
		}
	}

	ns.showProgressPanelAtXY = function(message, xy) {
		return ns.showProgressPanel(message, {
			close: false,
			draggable: false,
			zindex: XRM.zindex,
			visible: false,
			xy: xy,
			constraintoviewport: true
		});
	}

	ns.showModalProgressPanel = function(message) {
		var body = $(document.body);

		var hadClass = body.hasClass(yuiSkinClass);

		if (!hadClass) {
			body.addClass(yuiSkinClass);
		}

		var hideProgressPanel = ns.showProgressPanel(message, {
			close: false,
			draggable: false,
			zindex: XRM.zindex,
			visible: false,
			fixedcenter: true,
			modal: true
		});

		return function() {
			hideProgressPanel();

			if (!hadClass) {
				body.removeClass(yuiSkinClass);
			}
		}
	}
	
	ns.showError = function(message) {
		alert(message);
	}

	ns.showDataServiceError = function(xhr, message) {
		var xhrs = $.isArray(xhr) ? xhr : [xhr];
		message = message || XRM.localize('error.dataservice.default');

		$.each(xhrs, function(i, item) {
			// Try get an ADO.NET DataServicesException message out of the response JSON, and
			// append it to the error message.
			try {
				var errorJSON = JSON.parse(item.responseText);

				if (errorJSON && errorJSON.error && errorJSON.error.message && errorJSON.error.message.value) {
					message += '\n\n' + errorJSON.error.message.value;
				}
			}
			catch (e) { }
		});

		ns.showError(message);
	}
	
	ns.getEditLabel = function(containerElement) {
		return XRM.localize('editable.label');
	}
	
	ns.getEditTooltip = function(containerElement) {
		return XRM.localize('editable.tooltip')
	}
	
	$.fn.extend({
		editable: function(serviceUri, options) {
			var options = options || {};
			var container = this;
			var containerElement = container.get(0);

			var yuiContainer = $('<span />').addClass(yuiSkinClass).appendTo(container);
			var panelContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-controls').appendTo(yuiContainer);

			var editPanel = new YAHOO.widget.Panel(panelContainer.get(0), {
				close: false,
				draggable: false,
				constraintoviewport: true,
				visible: false,
				zindex: XRM.zindex
			});

			editPanel.setBody('<a class="xrm-editable-edit"></a>');
			editPanel.render();
			
			$('.xrm-editable-edit', editPanel.body).attr('title', XRM.ui.getEditTooltip(containerElement)).text(XRM.ui.getEditLabel(containerElement)).click(function() {
				var hideProgressPanel = XRM.ui.showProgressPanelAtXY(XRM.localize('editable.loading'), YAHOO.util.Dom.getXY(containerElement));

				// Retrieve the latest value data for the attribute, as JSON, and enter edit mode
				// when (if) it returns successfully.
				XRM.data.getJSON(serviceUri, {
					success: function(data, textStatus) {
						hideProgressPanel();

						if ($.isFunction(options.loadSuccess)) {
							options.loadSuccess(data);
						}
					},
					error: function(xhr) {
						hideProgressPanel();

						if ($.isFunction(options.loadError)) {
							options.loadError(xhr);
						}
						else {
							XRM.ui.showDataServiceError(xhr);
						}
					}
				});
			});
			
			var timeoutID;

			container.hover(
				function() {
					if (timeoutID) {
						clearTimeout(timeoutID);
					}
					container.addClass('xrm-editable-hover');
					editPanel.cfg.setProperty('xy', YAHOO.util.Dom.getXY(containerElement));
					editPanel.show();
				},
				function() {
					timeoutID = setTimeout(function() {
						editPanel.hide();
						container.removeClass('xrm-editable-hover');
					}, 800);
				}
			);
		},

		noneditable: function() {
			this.unbind('mouseenter').unbind('mouseleave');
		}
	});
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('ui');
	var Event = YAHOO.util.Event, Dom = YAHOO.util.Dom, $ = XRM.jQuery;
	
	function DateTimePicker(element, id) {
		this._element = $(element);
		this._id = id;
		this._rendered = false;
	}
	
	DateTimePicker.prototype.getSelectedDateTime = function() {
		if (!this._rendered) {
			return null;
		}
		
		var month = this._monthSelect.val();
		var day = this._dateSelect.val();
		var year = this._yearInput.val();
		var time = this._timeSelect.val();
		
		var splitTime = (time || '00:00').split(':');
		
		if (year && month && day && splitTime.length == 2) {
			var datetime = new Date();
			
			datetime.setFullYear(year, month, day);
			
			datetime.setHours(splitTime[0]);
			datetime.setMinutes(splitTime[1]);
			datetime.setSeconds(0, 0);
			
			return datetime;
		}
		
		return null;
	}
	
	var dataServiceDateRegexp = /Date\((\d+)\)/;
	
	function parseDateTime(value) {
		if (typeof(value) === 'string') {
			var standardParse = Date.parse(value);
			
			if (standardParse) {
				return standardParse;
			}
			
			var captures = dataServiceDateRegexp.exec(value);
			
			if (captures && captures.length > 1) {
				var ticks = parseFloat(captures[1]);
				
				if (typeof (ticks) === 'number') {
					return new Date(ticks);
				}
			}
					
			return null;
		}
		else {
			return new Date(value);
		}
	}
	
	function getTimeString(hours, minutes) {
		var h = (hours < 10) ? ('0' + hours) : ('' + hours);
		var m = (minutes < 30) ? '00' : '30';
		return h + ':' + m;
	}
	
	DateTimePicker.prototype.setSelectedDateTime = function(value) {
		var datetime = parseDateTime(value);
		
		if (!this._rendered) {
			this._selectedDateTime = datetime;
			return;
		}
		
		this._yearInput.val(datetime.getFullYear());
		this._monthSelect.val(datetime.getMonth());
		this._dateSelect.val(datetime.getDate());
		this._timeSelect.val(getTimeString(datetime.getHours(), datetime.getMinutes()));
		this._dateButton.set("label", datetime.toLocaleDateString());
	}
		
	DateTimePicker.prototype.render = function() {
		if (this._rendered) {
			return;
		}
		
		var element = this._element, id = this._id;
		
		// Create the DOM required to support our picker.
		var container = $('<div />').addClass('xrm-datetime').attr('id', id).appendTo(element);
		var dateFields = $('<div />').addClass('xrm-date').attr('id', id + '-datefields').appendTo(container);
		var timeFields = $('<div />').addClass('xrm-time').appendTo(container);
		
		function createSelect(name, selectContainer) {
			return $('<select />').attr('id', id + '-' + name).attr('name', id + '-' + name).appendTo(selectContainer);
		}
		
		var time = this._timeSelect = createSelect('time', timeFields);
		
		// Populate time select.
		for (var i = 0; i < 24; i++) {
			var onThehour = getTimeString(i, 0);
			$('<option />').val(onThehour).text(onThehour).appendTo(time);
			var onTheHalfHour = getTimeString(i, 30);
			$('<option />').val(onTheHalfHour).text(onTheHalfHour).appendTo(time);
		}
		
		var month = this._monthSelect = createSelect('month', dateFields).addClass('xrm-date-month').hide();
		
		$('<option />').val('').text('').appendTo(month);
		
		for (var i = 0; i < 12; i++) {
			$('<option />').val(i).text(i).appendTo(month);
		}
		
		var day = this._dateSelect = createSelect('day', dateFields).addClass('xrm-date-day').hide();
		
		$('<option />').val('').text('').appendTo(day);
		
		for (var i = 1; i <= 31; i++) {
			$('<option />').val(i).text(i).appendTo(day);
		}
		
		var year = this._yearInput = $('<input />').addClass('xrm-date-year').hide().attr('type', 'text').attr('id', id + '-year').attr('name', id + '-year').appendTo(dateFields);
		
		var calendarMenu, dateButton;
		
		function onDateButtonClick() {
			var calendarID = id + '-buttoncalendar';
			
			// Create a Calendar instance and render it into the body 
			// element of the Overlay.
			var calendar = new YAHOO.widget.Calendar(calendarID, calendarMenu.body.id);
			
			calendar.render();
			
			// Subscribe to the Calendar instance's "select" event to 
			// update the Button instance's label when the user
			// selects a date.
			calendar.selectEvent.subscribe(function (p_sType, p_aArgs) {
				var aDate, nMonth, nDay, nYear;
				
				if (p_aArgs) {
					aDate = p_aArgs[0][0];
					nMonth = aDate[1];
					nDay = aDate[2];
					nYear = aDate[0];
					
					var selectedDate = new Date();
					selectedDate.setFullYear(nYear, nMonth - 1, nDay);
					dateButton.set("label", selectedDate.toLocaleDateString());
					
					// Sync the Calendar instance's selected date with the date form fields.
					month.val(nMonth - 1);
					day.val(nDay);
					year.val(nYear);
				}
				
				calendarMenu.hide();
			})
			
			// Pressing the Esc key will hide the Calendar Menu and send focus back to 
			// its parent Button.
			Event.on(calendarMenu.element, "keydown", function (p_oEvent) {
				if (Event.getCharCode(p_oEvent) === 27) {
					calendarMenu.hide();
					this.focus();
				}
			}, null, this);
			
			var focusDay = function () {
				var oCalendarTBody = Dom.get(calendarID).tBodies[0],
					aElements = oCalendarTBody.getElementsByTagName("a"),
					oAnchor;
					
				if (aElements.length > 0) {
					Dom.batch(aElements, function (element) {
						if (Dom.hasClass(element.parentNode, "today")) {
							oAnchor = element;
						}
					});
					
					if (!oAnchor) {
						oAnchor = aElements[0];
					}
					
					// Focus the anchor element using a timer since Calendar will try 
					// to set focus to its next button by default.
					YAHOO.lang.later(0, oAnchor, function () {
						try {
							oAnchor.focus();
						}
						catch(e) {}
					});
				}
			};
			
			// Set focus to either the current day, or first day of the month in 
			// the Calendar when it is made visible or the month changes.
			calendarMenu.subscribe("show", focusDay);
			calendar.renderEvent.subscribe(focusDay, calendar, true);
			
			// Give the Calendar an initial focus.
			focusDay.call(calendar);
			
			// Re-align the CalendarMenu to the Button to ensure that it is in the correct
			// position when it is initial made visible.
			calendarMenu.align();
			
			// Unsubscribe from the "click" event so that this code is 
			// only executed once.
			this.unsubscribe("click", onDateButtonClick);
		}
		
		// Create a Overlay instance to house the Calendar instance.
		calendarMenu = new YAHOO.widget.Overlay(id + "-calendarmenu", { visible: false, iframe: true });
		
		// Create a Button instance of type "menu".
		dateButton = new YAHOO.widget.Button({ 
			type: "menu", 
			id: id + "-calendarpicker", 
			label: XRM.localize('datetimepicker.datepicker.label'), 
			menu: calendarMenu, 
			container: dateFields.attr('id') 
		});
		
		dateButton.on("appendTo", function () {
			// Create an empty body element for the Overlay instance in order 
			// to reserve space to render the Calendar instance into.
			calendarMenu.setBody("&#32;");
			calendarMenu.body.id = id + "-calendarcontainer";
		});
		
		// Add a listener for the "click" event.  This listener will be
		// used to defer the creation the Calendar instance until the 
		// first time the Button's Overlay instance is requested to be displayed
		// by the user.
		dateButton.on("click", onDateButtonClick);
		
		this._dateButton = dateButton;
		this._rendered = true;
		
		if (this._selectedDateTime) {
			this.setSelectedDateTime(this._selectedDateTime);
		}
	}
	
	ns.DateTimePicker = DateTimePicker;
		
});

XRM.onActivate(function() {
	
	var ns = XRM.namespace('editable.Attribute');
	var $ = XRM.jQuery;
	
	ns.attributeServiceUriParseRegexp = /^(.+)\/(.+)$/;
	
	if (!ns.handlers) {
		ns.handlers = {};
	}
	
	ns.initialize = function(toolbar) {
		$('.xrm-attribute').each(function() {
			var attributeContainer = $(this);
			var attributeServiceRef = $('a.xrm-attribute-ref', attributeContainer);
			var attributeServiceUri = attributeServiceRef.attr('href');
			var attributeDisplayName = attributeServiceRef.attr('title');

			// If there's no service URI for the attribute, quit.
			if (!attributeServiceUri) {
				return;
			}

			// Apply a special class to empty attributes, so we can make them visible/hoverable, through CSS.
			ns.addClassOnEmptyValue(attributeContainer);

			attributeContainer.editable(attributeServiceUri, {
				loadSuccess: function(attributeData) {
					ns.enterEditMode(attributeContainer, attributeServiceUri, attributeData, attributeDisplayName);
				}
			});
		});
	}
	
	ns.enterEditMode = function(attributeContainer, attributeServiceUri, attributeData, attributeDisplayName) {
		// If we have no valid attribute data, quit.
		if (!(attributeData && attributeData.d)) {
			return;
		}
		
		// For example, this would split the attribute service URI
		// "/Cms.svc/WebPages(guid'8714a5bd-0dfd-dd11-bdf3-0003ff48c0db')/Copy" into
		// ["", "/Cms.svc/WebPages(guid'8714a5bd-0dfd-dd11-bdf3-0003ff48c0db')", "Copy", ""].
		// [1] and [2] are the pieces of information we want (the empty strings are just junk).
		var uriSegments = ns.attributeServiceUriParseRegexp.exec(attributeServiceUri)

		// If we fail to extract the service URI info we need, quit.
		if (!uriSegments || (uriSegments.length < 3)) {
			return;
		}

		var entityServiceUri = uriSegments[1];
		var attributeName = uriSegments[2];

		// If we fail to extract the service URI info we need, quit.
		if (!(entityServiceUri && attributeName)) {
			return;
		}

		// For example, for the class "xrm-attribute xrm-editable-html foo", this would capture
		// ["xrm-editable-html", "html"]. We want [1] in this case.
		var captures = XRM.editable.editableClassRegexp.exec(attributeContainer.attr('class'));

		// If we fail to extract the editable type identifier we want, quit.
		if (!captures || (captures.length < 2)) {
			return;
		}

		var editableTypeHandler = ns.handlers[captures[1]];

		// If our editable type identifier doesn't correspond to an actual handler function, quit.
		if (!$.isFunction(editableTypeHandler)) {
			return;
		}

		var attributeValue = attributeData.d[attributeName];

		editableTypeHandler(attributeContainer, attributeDisplayName, attributeName, attributeValue, entityServiceUri, function() {
			ns.addClassOnEmptyValue(attributeContainer);
		});
	}

	ns.addClassOnEmptyValue = function(attributeContainer) {
		var attributeValue = $('.xrm-attribute-value', attributeContainer);

		if (attributeValue.html() == '') {
			attributeValue.addClass('xrm-attribute-value-empty');
		}
		else {
			attributeValue.removeClass('xrm-attribute-value-empty');
		}
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Attribute.handlers');
	var $ = XRM.jQuery;
	var yuiSkinClass = XRM.yuiSkinClass;
	
	ns.text = function(attributeContainer, attributeDisplayName, attributeName, attributeValue, entityServiceUri, editCompleteCallback) {
		// Build the DOM necessary to support our UI.
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog').appendTo(yuiContainer);

		function completeEdit(dialog) {
			dialog.cancel();
			yuiContainer.remove();

			if ($.isFunction(editCompleteCallback)) {
				editCompleteCallback();
			}
		}

		function handleCancel(dialog) {
			completeEdit(dialog);
		}

		function handleSave(dialog) {
			var dialogInput = $('.xrm-text', dialog.body);
			var dialogInputValue = dialogInput.val();
			var dialogFooter = $(dialog.footer);

			// If the attribute value has been changed, persist the new value.
			if (dialogInputValue != attributeValue) {
				dialogFooter.hide();
				dialogInput.hide();
				dialogContainer.addClass('xrm-editable-wait');
				XRM.data.services.putAttribute(entityServiceUri, attributeName, dialogInputValue, {
					success: function() {
						$('.xrm-attribute-value', attributeContainer).html(dialogInputValue);
						completeEdit(dialog);
					},
					error: function(xhr) {
						dialogContainer.removeClass('xrm-editable-wait');
						dialogFooter.show();
						dialogInput.show();
						XRM.ui.showDataServiceError(xhr);
					}
				});
			}
			// Otherwise, just dismiss the edit dialog without doing anything.
			else {
				completeEdit(dialog);
			}
		}

		// Create our modal editing dialog.
		var dialog = new YAHOO.widget.Dialog(dialogContainer.get(0), {
			visible: false,
			constraintoviewport: true,
			zindex: XRM.zindex,
			xy: YAHOO.util.Dom.getXY(attributeContainer.get(0)),
			buttons: [
				{ text: XRM.localize('editable.save.label'), handler: function() { handleSave(this) }, isDefault: true },
				{ text: XRM.localize('editable.cancel.label'), handler: function() { handleCancel(this) } }]
		});

		dialog.setHeader('Edit ' + (attributeDisplayName || ''));
		dialog.setBody(' ');
		
		$('<input />').attr('type', 'text').addClass('xrm-text').val(attributeValue || '').appendTo(dialog.body);

		// Add ctrl+s shortcut for saving content.
		$('.xrm-text', dialog.body).keypress(function(e) {
			if (!(e.which == ('s').charCodeAt(0) && e.ctrlKey)) {
				return true;
			}
			handleSave(dialog);
			return false;
		});

		dialog.render();
		dialog.show();

		XRM.ui.registerOverlay(dialog);
		dialog.focus();

		$('.xrm-text', dialog.body).focus();
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Attribute.handlers');
	var $ = XRM.jQuery;
	var yuiSkinClass = XRM.yuiSkinClass;
	
	function renderRichUI(attributeContainer, attributeDisplayName, attributeName, attributeValue, entityServiceUri, editCompleteCallback) {
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var panelContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-dialog-html').appendTo(yuiContainer);

		var editPanel = new YAHOO.widget.Panel(panelContainer.get(0), {
			close: false,
			draggable: true,
			constraintoviewport: true,
			visible: false,
			zindex: XRM.zindex,
			xy: YAHOO.util.Dom.getXY(attributeContainer.get(0))
		});

		editPanel.setHeader(XRM.localize('editable.label.prefix') + attributeDisplayName);
		editPanel.setBody(' ');
		editPanel.render();
		editPanel.show();

		XRM.ui.registerOverlay(editPanel);
		editPanel.focus();

		var id = tinymce.DOM.uniqueId();

		// Create the textarea that will host our content, and that tinymce will latch on to.
		$('<textarea />').attr('id', id).text(attributeValue || '').appendTo(editPanel.body);

		// Create our tinymce editor, and wire up the custom save/cancel handling.
		var editor = new tinymce.Editor(id, XRM.tinymceSettings);

		editor.onClick.add(function() { editPanel.focus(); });

		editor.addButton('save', { title: 'save.save_desc', cmd: 'xrmSave' });
		editor.addButton('cancel', { title: 'save.cancel_desc', cmd: 'xrmCancel' });

		editor.addShortcut('ctrl+s', editor.getLang('save.save_desc'), 'xrmSave');

		function removeEditor() {
			editPanel.hide();
			editor.remove();
			yuiContainer.remove();
		}

		editor.addCommand('xrmSave', function() {
			// Don't bother with the ajax call if nothing was changed.
			if (!editor.isDirty()) {
				removeEditor();
				return;
			}

			editor.setProgressState(1);
			var content = editor.getContent();

			XRM.data.services.putAttribute(entityServiceUri, attributeName, content, {
				success: function() {
					editor.setProgressState(0);
					// Set the original in-DOM content to the new content exported from tinymce.
					$('.xrm-attribute-value', attributeContainer).html(content);
					removeEditor();

					if ($.isFunction(editCompleteCallback)) {
						editCompleteCallback();
					}
				},
				error: function(xhr) {
					editor.setProgressState(0);
					XRM.ui.showDataServiceError(xhr);
				}
			});
		});

		editor.addCommand('xrmCancel', function() {
			if (editor.isDirty()) {
				if (!confirm(XRM.localize('confirm.unsavedchanges'))) {
					return;
				}
			}

			removeEditor();

			if ($.isFunction(editCompleteCallback)) {
				editCompleteCallback();
			}
		});

		editor.render();
	}
	
	function renderFallbackUI(attributeContainer, attributeDisplayName, attributeName, attributeValue, entityServiceUri, editCompleteCallback) {
		// Build the DOM necessary to support our UI.
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-dialog-html-fallback').appendTo(yuiContainer);

		function completeEdit(dialog) {
			dialog.cancel();
			yuiContainer.remove();

			if ($.isFunction(editCompleteCallback)) {
				editCompleteCallback();
			}
		}

		function handleCancel(dialog) {
			completeEdit(dialog);
		}

		function handleSave(dialog) {
			var dialogInput = $('.xrm-text', dialog.body);
			var dialogInputValue = dialogInput.val();
			var dialogFooter = $(dialog.footer);

			// If the attribute value has been changed, persist the new value.
			if (dialogInputValue != attributeValue) {
				dialogFooter.hide();
				dialogInput.hide();
				dialogContainer.addClass('xrm-editable-wait');
				XRM.data.services.putAttribute(entityServiceUri, attributeName, dialogInputValue, {
					success: function() {
						$('.xrm-attribute-value', attributeContainer).html(dialogInputValue);
						completeEdit(dialog);
					},
					error: function(xhr) {
						dialogContainer.removeClass('xrm-editable-wait');
						dialogFooter.show();
						dialogInput.show();
						XRM.ui.showDataServiceError(xhr);
					}
				});
			}
			// Otherwise, just dismiss the edit dialog without doing anything.
			else {
				completeEdit(dialog);
			}
		}

		// Create our modal editing dialog.
		var dialog = new YAHOO.widget.Dialog(dialogContainer.get(0), {
			visible: false,
			constraintoviewport: true,
			zindex: XRM.zindex,
			xy: YAHOO.util.Dom.getXY(attributeContainer.get(0)),
			buttons: [
				{ text: XRM.localize('editable.save.label'), handler: function() { handleSave(this) }, isDefault: true },
				{ text: XRM.localize('editable.cancel.label'), handler: function() { handleCancel(this) } }]
		});

		dialog.setHeader('Edit ' + (attributeDisplayName || ''));
		dialog.setBody(' ');
		
		$('<textarea />').addClass('xrm-text').val(attributeValue || '').appendTo(dialog.body);

		// Add ctrl+s shortcut for saving content.
		$('.xrm-text', dialog.body).keypress(function(e) {
			if (!(e.which == ('s').charCodeAt(0) && e.ctrlKey)) {
				return true;
			}
			handleSave(dialog);
			return false;
		});

		dialog.render();
		dialog.show();

		XRM.ui.registerOverlay(dialog);
		dialog.focus();

		$('.xrm-text', dialog.body).focus();
	}
	
	ns.html = (typeof(tinymce) === 'undefined') ? renderFallbackUI : renderRichUI;
	
});

XRM.onActivate(function() {
	
	var ns = XRM.namespace('editable.Entity');
	var $ = XRM.jQuery;
	var editableClassRegexp = XRM.editable.editableClassRegexp;
	var yuiSkinClass = XRM.yuiSkinClass;
	var JSON = YAHOO.lang.JSON;
	
	if (!ns.handlers) {
		ns.handlers = {};
	}
	
	ns.initialize = function(toolbar) {
		$('.xrm-entity').each(function() {
			var entityContainer = $(this);

			// For example, for the class "xrm-entity xrm-editable-webpage foo", this would capture
			// ["xrm-editable-webpage", "webpage"]. We want [1] in this case.
			var captures = editableClassRegexp.exec(entityContainer.attr('class'));

			// If we fail to extract the editable type identifier we want, quit.
			if (!captures || (captures.length < 2)) {
				return;
			}

			var editableTypeHandler = ns.handlers[captures[1]];

			// If our editable type identifier doesn't correspond to an actual handler function, quit.
			if (!$.isFunction(editableTypeHandler)) {
				return;
			}

			editableTypeHandler(entityContainer, toolbar);
		});
	}
	
	// In all current usages, entityDisplayName is a string literal comes from the XRM.localizations
	// dictionary. For example, "adx_webpage.shortname" => "page".
	ns.createDeleteButton = function(entityContainer, entityDeleteUri, entityDisplayName, container) {
		return new YAHOO.widget.Button({
			container: container,
			label: XRM.localize('editable.delete.label'),
			title: XRM.util.StringFormatter.format(XRM.localize('editable.delete.tooltip.prefix'), entityDisplayName),
			onclick: { fn: function() { ns.showDeletionDialog(entityContainer, entityDeleteUri, entityDisplayName); } }
		});
	}
	
	ns.deleteEntity = function(entityContainer, entityDeleteUri) {
		XRM.data.postJSON(entityDeleteUri, {}, {
			success: function () {
				var redirectUrl = $(".xrm-entity-parent-url-ref", entityContainer).attr('href');
				document.location = redirectUrl && XRM.util.isSameDomain(redirectUrl) ? redirectUrl : '/'
			},
			error: function(xhr) {
				XRM.ui.showDataServiceError(xhr);
			}
		});
	}
	
	ns.showDeletionDialog = function(entityContainer, entityUri, entityDisplayName) {
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog').appendTo(document.body);

		function closeDialog(dialog) {
			dialog.cancel();
			dialogContainer.remove();
			$(document.body).removeClass(yuiSkinClass);
		}

		function handleYes() {
			ns.deleteEntity(entityContainer, entityUri);
			closeDialog(this);
		}

		function handleNo() {
			closeDialog(this);
		}

		var dialog = new YAHOO.widget.SimpleDialog(dialogContainer.get(0), {
			fixedcenter: true,
			visible: false,
			draggable: false,
			close: false,
			modal: true,
			icon: YAHOO.widget.SimpleDialog.ICON_WARN,
			constraintoviewport: true,
			buttons: [{ text: XRM.localize('confirm.yes'), handler: handleYes, isDefault: true }, { text: XRM.localize('confirm.no'), handler: handleNo}]
		});
		
		dialog.setHeader(' ');
		dialog.setBody(' ');
		
		// In all current usages, entityDisplayName is a string literal comes from the XRM.localizations
		// dictionary. For example, "adx_webpage.shortname" => "page". In this example, as well, jQuery's
		// text() function will do HTML escaping.
		$('<span />').text(XRM.localize('editable.delete.tooltip.prefix') + entityDisplayName + '?').appendTo(dialog.header);
		$('<p />').text(XRM.localize('confirm.delete.entity.prefix') + entityDisplayName + '?').appendTo(dialog.body);
		
		var siteMarkerWarning = ns.getSiteMarkerWarning(entityContainer, entityDisplayName);
		
		if (siteMarkerWarning) {
			$('<p />').text(siteMarkerWarning).appendTo(dialog.body);
		}
		
		$(document.body).addClass(yuiSkinClass);

		dialog.render();
		dialog.show();
		XRM.ui.registerOverlay(dialog);
		dialog.focus();
	}
	
	ns.getSiteMarkerWarning = function(entityContainer, entityDisplayName) {
		// Gather the site markers associated with this entity, and warn the user about these
		// existing associations.
		var siteMarkers = [];
		
		$('.xrm-entity-adx_webpage_sitemarker', entityContainer).each(function() {
			siteMarkers.push('"' + $(this).attr('title') + '"');
		});
		
		if (siteMarkers.length < 1) {
			return null;
		}
		
		// In all current usages, entityDisplayName is a string literal comes from the XRM.localizations
		// dictionary. For example, "adx_webpage.shortname" => "page". This string will also be passed
		// through jQuery's text() function before being rendered, which does HTML escaping (see line 100-103).
		return "This " +
			entityDisplayName +
			" is associated with the sitemarker" +
			((siteMarkers.length > 1) ? "s" : "") +
			" " +
			siteMarkers.join(', ') +
			". Site functionality may depend on this association.";
	}
	
	// The form parameter of this funtion is an object that forms a "specification" for an editing dialog.
	// This object must conform to a specific structure (specifies a form title, the service URI of the
	// entity being edited, etc.), and also specifies the form fields to be rendered, and their properties.
	// For example (also see entities/adx_webpage.js for another example):
	//
	// var webPageForm = {
	//  uri: "/Services/Cms.svc/adx_webpages(guid'00000000-0000-0000-0000-000000000000')", // Often populated from metadata embedded in the DOM, rendered by framework webcontrols (for example, Microsoft.Xrm.Portals.Web.UI.WebControls.Property).
	//  urlServiceUri: "/Services/Cms.svc/GetEntityUrl?entitySet='adx_webpages'&entityID=guid'00000000-0000-0000-0000-000000000000'", // Usually populated from metadata rendered to the DOM.
	//  urlServiceUriTemplate: null,
	//  title: "Edit this page", // Usually populated from a lookup to XRM.localizations.
	//  entityName: 'adx_webpage',
	//  fields: [
	//   { name: 'adx_name', label: 'Name', type: 'text', required: true },
	//   { name: 'adx_partialurl', label: 'Partial URL', type: 'text', required: true, slugify: 'adx_name' },
	//   { name: 'adx_pagetemplateid', label: 'Page Template', type: 'select', excludeEmptyData: true, required: true, uri: "/Services/Cms.svc/adx_pagetemplates", optionEntityName: 'adx_pagetemplate', optionText: 'adx_name', optionValue: 'adx_pagetemplateid', sortby: 'adx_name' },
	//   { name: 'adx_displaydate', label: 'Display Date', type: 'datetime', excludeEmptyData: true },
	//   { name: 'adx_hiddenfromsitemap', label: 'Hidden from Sitemap', type: 'checkbox' }
	//  ]
	// };
	//
	// The "fields" array here dictates the form fields that will be rendered for this dialog (and whether they are required fields, etc.).
	// The "type" property of a field (e.g., "text") will lookup a class in XRM.editable.Entity.Form.fieldTypes (e.g., fieldTypes["text"]).
	// These classes are then responsible for the actual rendering/UI of each supported field type. The definition of these types can be
	// found in entity_form.js. 
	ns.showEntityDialog = function(form, options) {
		options = options || {};
		
		if (!form) {
			return XRM.log('"form" cannot be null.', 'error', 'XRM.editable.Entity.showCreationDialog');
		}
		
		// Create a DOM container for our dialog.
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-dialog-create').appendTo(document.body);
		
		// Map array of form field definition objects to actual form field type handler objects (see comment block on showEntityDialog).
		var fields = $.map(form.fields, function(field) {
			var type = ns.Form.fieldTypes[field.type];
			return type ? new type(form.entityName, field) : null;
		});

		function closeDialog(dialog) {
			dialog.cancel();
		}

		function cancel() {
			this.cancel();
		}

		function save() {
			var dialog = this;
			
			// Remove any previous validation error messages.			
			$('.xrm-dialog-validation-summary .xrm-dialog-validation-message', dialog.body).remove();
			
			// Do field validation.
			var valid = true;

			function addValidationError(message) {
				valid = false;
				// Add message through jQuery.text(), which will HTML escape. Message will also generally come 
				// from a combination of a field label (which is either hard-coded in the formPrototype of an
				// entity handler--entities/adx_webpage.js, for example--or retrieved from XRM.localizations) 
				// and a validation suffix retrieved from XRM.localizations.
				$('<span />').addClass('xrm-dialog-validation-message').text(message).appendTo($('.xrm-dialog-validation-summary', dialog.body));
			}

			$.each(fields, function(i, field) {
				if (!field.validate(dialog.body)) {
					addValidationError(field.label + XRM.localize('validation.required.suffix'));
				}
			});

			// Invalid input; stop the save process.
			if (!valid) {
				return;
			}
			
			var data = {};
			
			$.each(fields, function(i, field) { field.appendData(data, dialog.body); });
			
			options.save(form, data, {
				success: function() {
					closeDialog(dialog);
				}
			});
		}

		var dialog = new YAHOO.widget.Dialog(dialogContainer.get(0), {
			visible: false,
			constraintoviewport: true,
			fixedcenter: true,
			zindex: XRM.zindex,
			modal: true,
			buttons: [{ text: XRM.localize('editable.save.label'), handler: save, isDefault: true }, { text: XRM.localize('editable.cancel.label'), handler: cancel }]
		});

		dialog.subscribe('cancel', function () {
			dialogContainer.remove();
			$(document.body).removeClass(yuiSkinClass);

			if ($.isFunction(options.cancel)) {
				options.cancel();
			}
		});

		dialog.setHeader(' ');
		
		// form.title comes from form definition object provided as parameter, originally found in XRM.localizations.
		// See comment block on showEntityDialog for more. jQuery.text() will also perform HTML escaping here.
		$('<span />').text(form.title).appendTo(dialog.header);
		
		dialog.setBody(' ');

		// Generate the DOM for our form fields.
		$.each(fields, function(i, field) {
			var section = $('<div />').addClass('xrm-dialog-section').appendTo(dialog.body);
			var label = $('<label />').attr('for', field.id).text(field.label + (field.required ? ' ' + XRM.localize('editable.required.label') : '')).appendTo(section);
			
			field.render(section, label);
		});

		$('<div />').addClass("xrm-dialog-validation-summary").appendTo(dialog.body);

		// Set up any sync-slugification specified by any fields.
		$.each(fields, function(i, field) {
			if (field.slugify) {
				var targets = $.grep(fields, function(f) { return f.name == field.slugify });
				
				for (var i = 0; i < targets.length; i++) {
					$('#' + field.id, dialog.body).syncSlugify($('#' + targets[i].id, dialog.body));
				}
			}
		});

		var hideProgressPanel = XRM.ui.showModalProgressPanel(XRM.localize('editable.loading'));

		function showDialog() {
			dialog.render();
			hideProgressPanel();

			// Add this class to the document body, so that YUI modal dialog effects work
			// properly. We'll clean up this class when our dialog closes.
			$(document.body).addClass(yuiSkinClass);
			
			$.each(fields, function(i, field) { field.show(dialog) });
			
			dialog.show();
			XRM.ui.registerOverlay(dialog);
			dialog.focus();
			$('input:first', dialog.body).focus();
		}
		
		// Load any remote data required by any select fields.
		var fieldsToLoad = $.grep(fields, function(field) { return field.requiresLoading });
		
		if (fieldsToLoad.length < 1) {
			showDialog();
			return;
		}
		
		var completedLoads = [];

		function loadComplete(field) {
			completedLoads.push(field);

			if (completedLoads.length == fieldsToLoad.length) {
				showDialog();
			}
		}

		function loadError(field, xhr) {
			hideProgressPanel();
			closeDialog(dialog);
			XRM.ui.showDataServiceError(xhr, XRM.localize('error.dataservice.loading'));
		}

		function dataError(message) {
			hideProgressPanel();
			closeDialog(dialog);
			XRM.ui.showError(message);
		}

		$.each(fieldsToLoad, function(i, field) {
			XRM.data.getJSON(field.uri, {
				success: function(data, textStatus) {
					if (!(data && data.d)) {
						dataError(XRM.localize('error.dataservice.loading.field.prefix') + field.label + '.');
						return;
					}

					field.load(data, dialog.body);

					loadComplete(field);
				},
				error: function(xhr) {
					loadError(field, xhr);
				}
			});
		});
	}
	
	ns.showCreationDialog = function(form, options) {
		options = options || {};
		
		if (!$.isFunction(options.save)) {
			options.save = saveCreationDialog;
		}
		
		ns.showEntityDialog(form, options);
	}
	
	function saveCreationDialog(form, data, options) {
		options.processData = true;
		saveEntityDialog(form, data, options);
	}
	
	function saveEntityDialog(form, data, options) {
		if (!form.uri) {
			return XRM.log('"form.uri" must be defined.', 'error', 'XRM.editable.Entity.saveEntityDialog');
		}
		
		options = options || {};
		
		if (!$.isFunction(options.success)) {
			options.success = function() {};
		}
		
		var hideProgressPanel = XRM.ui.showModalProgressPanel(XRM.localize('editable.saving'));

		// Post our data to the creation URI. (Browser security demands that this be same-domain).
		// (See comment block on showEntityDialog for further explanation of form.uri, but this
		// value will be loaded originally from DOM metadata output by framework webcontrols.)
		XRM.data.postJSON(form.uri, data, {
			processData: options.processData,
			httpMethodOverride: options.httpMethodOverride,
			success: function(data, textStatus) {
				function done() {
					hideProgressPanel();
					options.success();
				}
				
				// If the reload option is set on the form definition, just reload the page.
				if (form.reload) {
					done();
					document.location = document.location;
					return;
				}
				
				function tryRedirectToEntity() {
					// Get the location of the new entity with a service call.
					var urlServiceUri = null;
					
					if (form.urlServiceUri) {
						urlServiceUri = form.urlServiceUri;
					}
					else if (form.urlServiceUriTemplate && data && data.d) {
						urlServiceUri = XRM.util.expandUriTemplate(form.urlServiceUriTemplate, data.d);
					}
					
					var urlServiceOperationName = form.urlServiceOperationName;
					
					if (urlServiceUri === null || (!urlServiceOperationName)) {
						done();
						return;
					}
					
					// Go to the data service to retrieve the URL of the newly-edited/created entity (the edit
					// may have changed its URL). The browser dictates that this AJAX request can be only made
					// same-domain, and we'll also validate that the URL returned from the service is same-domain
					// before we redirect to it.	
					XRM.data.getJSON(urlServiceUri, {
						success: function(urlData, textStatus) {
							if (urlData && urlData.d && urlData.d[urlServiceOperationName]) {
								var url = urlData.d[urlServiceOperationName];
								if (url) {
									if (XRM.util.isSameDomain(document.location, url)) {
										document.location = url;
									}
									else {
										XRM.log('Returned redirect URL "' + url + '" is not equal to current document.location.host "' + document.location.host + '". Skipping redirect.', 'error');
									}
								}
							}
							done();
						},
						error: function() { done(); }
					});
				}
				
				// Find all valid file upload fields.
				var fileUploads = $.map(form.fields, function(field) {
					return (field.type === 'file' && (field.fileUploadUri || field.fileUploadUriTemplate))
						? new ns.Form.fieldTypes.file(form.entityName, field)
						: null;
				});
							
				// No file uploads; try redirect and close dialog.
				if (fileUploads.length < 1) {
					tryRedirectToEntity();
					return;
				}
				
				var completedFileUploads = [];
				
				// Called to signal a completed file upload.
				function fileUploadComplete(field) {
					completedFileUploads.push(field);
					
					// If all file uploads are complete, try redirect, and close the dialog.
					if (completedFileUploads.length >= fileUploads.length) {
						tryRedirectToEntity();
					}
				}
				
				// Do any file uploads.
				$.each(fileUploads, function(i, field) {
					field.upload(data, function() { fileUploadComplete(field) });
				});
			},
			error: function(xhr, errorType, ex) {
				hideProgressPanel();
				XRM.log(errorType + ':' + ex, 'error');
				XRM.ui.showDataServiceError(xhr);
			}
		});
	}
	
	ns.showEditDialog = function(form, options) {
		if (!form.uri) {
			return XRM.log('"form.uri" must be defined.', 'error', 'XRM.editable.Entity.showEditDialog');
		}
		
		options = options || {};
		
		if (!$.isFunction(options.save)) {
			options.save = saveEditDialog;
		}
		
		var hideProgressPanel = XRM.ui.showModalProgressPanel('Loading...');
		
		function loadError(xhr, error, ex) {
			hideProgressPanel();
			XRM.log(error + ': ' + ex, 'error', 'XRM.editable.Entity.showEditDialog');
			XRM.ui.showDataServiceError(xhr, XRM.localize('error.dataservice.loading'));
		}

		// Load the entity data, and use it to populate the field values of the form. This is an AJAX
		// request, and so must be same-domain.
		// (See comment block on showEntityDialog for explanation of form.uri. form.uri will
		// have been originally loaded from metadata in the DOM, rendered by framework webcontrols.)
		XRM.data.getJSON(form.uri, {
			success: function(data, textStatus) {
				hideProgressPanel();
				
				if (!(data && data.d)) {
					XRM.ui.showError(XRM.localize('error.dataservice.loading'));
					return;
				}
				
				$.each(form.fields, function(i, field) {
					var propertyName = ns.getPropertyName(form.entityName, field.name);
					
					if (!propertyName) {
						return;
					}
					
					var propertyData = data.d[propertyName];
					
					if (typeof (propertyData) === 'undefined') {
						return;
					}
					
					field.value = propertyData;
				});
				
				ns.showEntityDialog(form, options);
			},
			error: loadError
		});
	}
	
	function saveEditDialog(form, data, options) {
		options.httpMethodOverride = 'MERGE';
		options.processData = false;
		saveEntityDialog(form, data, options);
	}
	
	var schemaMap = {};
	
	function loadSchemaMap() {
		$('.xrm-entity-schema-map').each(function() {
			var map = $(this);
			var entitySchemaName = map.attr('title');
			
			if (!entitySchemaName) {
				return;
			}
			
			var mapData = null;
			
			try {
				mapData = JSON.parse(map.text() || '[]');
			}
			catch (e) {
				XRM.log('Error loading XRM schema map data for entity "' + entitySchemaName + '": ' + e, 'error', 'XRM.editable.Entity.loadSchemaMap');
				mapData = []
			}
			
			var entityMap = {};
			
			$.each(mapData, function() { entityMap[this['Key']] = this['Value']; });
			
			schemaMap[entitySchemaName] = entityMap;
		});
	}
	
	$(document).ready(function() {
		loadSchemaMap();
	});
	
	ns.getPropertyName = function(entitySchemaName, propertySchemaName) {
		return schemaMap[entitySchemaName][propertySchemaName];
	}
	
});

XRM.onActivate(function () {

	var ns = XRM.namespace('editable.Entity.Form');
	var $ = XRM.jQuery;

	var initializing = false, fnTest = /xyz/.test(function () { xyz; }) ? /\b_super\b/ : /.*/;

	// The base Class implementation (does nothing)
	var Class = function () { };

	// Create a new Class that inherits from this class
	Class.extend = function (prop) {
		var _super = this.prototype;

		// Instantiate a base class (but only create the instance,
		// don't run the init constructor)
		initializing = true;
		var prototype = new this();
		initializing = false;

		// Copy the properties over onto the new prototype
		for (var name in prop) {
			// Check if we're overwriting an existing function
			prototype[name] = typeof prop[name] == "function" &&
				typeof _super[name] == "function" && fnTest.test(prop[name]) ?
				(function (name, fn) {
					return function () {
						var tmp = this._super;

						// Add a new ._super() method that is the same method
						// but on the super-class
						this._super = _super[name];

						// The method only need to be bound temporarily, so we
						// remove it when we're done executing
						var ret = fn.apply(this, arguments);
						this._super = tmp;

						return ret;
					};
				})(name, prop[name]) :
				prop[name];
		}

		// The dummy class constructor
		function Class() {
			// All construction is actually done in the init method
			if (!initializing && this.init)
				this.init.apply(this, arguments);
		}

		// Populate our constructed prototype object
		Class.prototype = prototype;

		// Enforce the constructor to be what we expect
		Class.constructor = Class;

		// And make this class extendable
		Class.extend = arguments.callee;

		return Class;
	};

	var FieldType = ns.FieldType = Class.extend({
		init: function (entityName, data) {
			this.id = data.id || this._getId(data.name);
			this.label = XRM.localize(entityName + '.' + data.name) || data.label || data.name;
			this.name = data.name;
			this.propertyName = XRM.editable.Entity.getPropertyName(entityName, data.name);
			this.required = data.required;
			this.requiresLoading = !!data.uri;
			this.slugify = data.slugify;
			this.uri = data.uri;

			this._data = data;
			this._entityName = entityName;
			this._initialValue = data.value;
		},

		appendData: function (data, container) {
			var value = this.getValue(container);

			if (this._data.excludeEmptyData && ((typeof (value) === 'undefined') || (value === null) || (value === ''))) {
				return;
			}

			data[this.propertyName] = value;

			if (this._data.mirror) {
				data[XRM.editable.Entity.getPropertyName(this._entityName, this._data.mirror)] = value;
			}

			return data;
		},

		getValue: function (container) {
			return $('#' + this.id, container || document).val();
		},

		load: function (data, container) { },

		render: function (container, label) { },

		show: function (dialog) { },

		validate: function (container) {
			return !!(!this.required || this.getValue(container));
		},

		_getId: function (fieldName) {
			return 'xrm-editable-' + fieldName;
		}
	});

	var types = ns.fieldTypes = {};

	types.text = FieldType.extend({
		render: function (container, label) {
			var textbox = $('<input />').attr('type', 'text').attr('id', this.id).attr('name', this.id).addClass('xrm-text').appendTo(container);

			if (typeof (this._initialValue) !== 'undefined' && this._initialValue !== null) {
				textbox.val(this._initialValue || '');
			}
		}
	});

	types.html = FieldType.extend({
		getValue: function (container) {
			return this._editor ? this._editor.getContent() : $('#' + this.id, container || document).val(); ;
		},

		render: function (container, label) {
			var textbox = $('<textarea />').attr('id', this.id).attr('name', this.id).addClass('xrm-html').appendTo(container);

			if (typeof (this._initialValue) !== 'undefined' && this._initialValue !== null) {
				textbox.val(this._initialValue || '');
			}

			if (typeof (tinymce) !== 'undefined') {
				this._editor = new tinymce.Editor(textbox.attr('id'), XRM.tinymceCompactSettings);
			}
			else {
				this._editor = null;
			}
		},

		show: function (dialog) {
			var editor = this._editor;
			if (editor) {
				editor.onClick.add(function () {
					if (dialog && dialog.focus) dialog.focus();
				});
				editor.render();
			}
		}
	});

	types.checkbox = FieldType.extend({
		getValue: function (container) {
			return $('#' + this.id, container || document).is(':checked');
		},

		render: function (container, label) {
			label.addClass('xrm-checkbox');
			var checkbox = $('<input />').attr('type', 'checkbox').attr('id', this.id).attr('name', this.id).prependTo(label);

			if (typeof (this._initialValue) !== 'undefined' && this._initialValue !== null) {
				checkbox.attr('checked', this._initialValue);
			}
		}
	});

	types.select = FieldType.extend({
		load: function (data, container) {
			var element = $('#' + this.id, container || document);

			var field = this._data;

			function getOptionPropertyName(propertySchemaName) {
				return field.optionEntityName ? XRM.editable.Entity.getPropertyName(field.optionEntityName, propertySchemaName) : propertySchemaName;
			}

			var items = $.isArray(data.d) ? data.d : [];

			// Sort elements if specified.
			if (field.sortby) {
				var sortPropertyName = getOptionPropertyName(field.sortby);

				items.sort(function (a, b) {
					var aOrder = a[sortPropertyName], bOrder = b[sortPropertyName];
					if (aOrder < bOrder) return -1;
					if (aOrder == bOrder) return 0;
					return 1;
				});
			}

			var textPropertyName = getOptionPropertyName(field.optionText);
			var valuePropertyName = getOptionPropertyName(field.optionValue);
			var isDefaultPropertyName = getOptionPropertyName('adx_isdefault');

			var isSelected = (field.value != null && typeof (field.value) !== 'undefined')
				? function (item) { return item[valuePropertyName] === (field.value.Id || field.value); }
				: function (item) { return !!item[isDefaultPropertyName]; };

			// Populate select with retrieved items.
			$.each(items, function (i, item) {
				$('<option />').val(item[valuePropertyName]).text(item[textPropertyName]).attr('selected', isSelected(item)).appendTo(element);
			});
		},

		appendData: function (data, container) {
			var value = this.getValue(container);

			if ((typeof (value) === 'undefined') || (value === null) || (value === '')) {
				if (!this._data.excludeEmptyData) {
					data[this.propertyName] = null;
				}

				return;
			}

			data[this.propertyName] = { "Id": value, "LogicalName": this._data.optionEntityName };

			return data;
		},

		render: function (container, label) {
			var select = $('<select />').attr('id', this.id).attr('name', this.id).appendTo(container);

			if (!this.required) {
				$('<option />').val('').text('').attr('selected', 'selected').appendTo(select);
			}
		}
	});

	types.datetime = FieldType.extend({
		getValue: function (container) {
			if (!this._picker) {
				return null;
			}
			var datetime = this._picker.getSelectedDateTime();
			return datetime ? XRM.util.formatDateForDataService(datetime) : null;
		},

		render: function (container, label) {
			var picker = new XRM.ui.DateTimePicker(container, this.id);
			picker.render();

			if (typeof (this._initialValue) !== 'undefined' && this._initialValue !== null) {
				picker.setSelectedDateTime(this._initialValue);
			}

			this._picker = picker;
		}
	});

	types.file = FieldType.extend({
		appendData: function (data, container) { },

		upload: function (data, onComplete) {
			var field = this._data,
			    uploadUri = null,
			    parsedUri,
			    message,
			    form;

			if (field.fileUploadUri) {
				uploadUri = field.fileUploadUri;
			}
			else if (field.fileUploadUriTemplate && data && data.d) {
				uploadUri = XRM.util.expandUriTemplate(field.fileUploadUriTemplate, data.d);
			}

			if (uploadUri === null) {
				return;
			}

			if (!XRM.util.isSameDomain(document.location, uploadUri)) {
				message = 'Host of upload URI "' + uploadUri + '" is not equal to current document.location.host "' + document.location.host + '". File upload failed.';
				XRM.log(message, 'error');
				alert(message);
				onComplete(this);
				return;
			}

			form = $('<form />')
				.attr('id', this.id + '-form')
				.attr('action', uploadUri)
				.attr('enctype', "multipart/form-data")
				.attr('method', 'post')
				.hide()
				.appendTo(document.body);

			$('#' + this.id).wrap(form);

			YAHOO.util.Connect.setForm(form.attr('id'), true, true);

			YAHOO.util.Connect.asyncRequest('POST', uploadUri, {
				upload: function (response) {
					form.remove();
					onComplete(this);
				}
			});
		},

		render: function (container, label) {
			var fileInput = $('<input />').attr('type', 'file').attr('id', this.id).attr('name', this.id).addClass('xrm-file').appendTo(container);

			var self = this;
			var field = this._data;

			fileInput.change(function () {
				if (field.copyFilenameTo) {
					var copyTo = $('#' + self._getId(field.copyFilenameTo));

					if (!copyTo.val()) {
						copyTo.val(self._getFilenameFromFileInput(fileInput));
					}
				}

				if (field.copyFilenameSlugTo) {
					var copyTo = $('#' + self._getId(field.copyFilenameSlugTo));

					if (!copyTo.val()) {
						copyTo.val(XRM.util.slugify(self._getFilenameFromFileInput(fileInput)));
					}
				}
			});
		},

		_getFilenameFromFileInput: function (fileInput) {
			var rawValue = fileInput.val();

			if (!rawValue) {
				return '';
			}

			var parts = rawValue.split('\\');

			return parts[parts.length - 1];
		}
	});

});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Entity.Handler');
	var Entity = XRM.editable.Entity;
	var $ = XRM.jQuery;
	
	ns.getForm = function(formPrototype, entityContainer, options) {
		var form = $.extend(true, {}, formPrototype);
		
		form.title = options.title;
		form.uri = options.uri;
		form.urlServiceUri = options.urlServiceUri;
		form.urlServiceUriTemplate = options.urlServiceUriTemplate;
		form.urlServiceOperationName = options.urlServiceOperationName;
		
		// The form is only presumed valid if it has a submission URI.
		form.valid = !!form.uri;
		
		$.each(form.fields, function() {
			var field = this;
			if (field.optionEntityName) {
				var data = $('a.xrm-entity-' + field.optionEntityName + '-ref', entityContainer).attr('href');
				
				if (!data) {
					form.valid = false;
				}
				
				field.uri = data;
			}
			
			if (this.type === 'file') {
				var data = $('a.xrm-uri-template.xrm-entity-' + field.name + '-ref', entityContainer).attr('href');
				
				if (!data) {
					form.valid = false;
				}
				
				field.fileUploadUriTemplate = data;
			}
		});
		
		return form;
	}
	
	ns.renderCreateButton = function(createOptions, entityContainer, toolbar, entityUri, label, tooltip) {
		var module = $('<div />').addClass('xrm-editable-toolbar-module').appendTo(toolbar.body).get(0);
			
		var menu = [];
		
		$.each(createOptions, function() {
			var option = this;
			var handler = Entity.handlers[option.entityName];
			
			if (!handler) return;
			
			var uri = $('a.xrm-entity-' + option.relationship + '-ref', entityContainer).attr('href');
			
			if (!uri) return;
			
			var urlServiceUriTemplate = $('a.xrm-entity-' + option.entityName + '-url-ref', entityContainer);
			
			var form = handler.getForm(entityContainer, {
				title: XRM.localize(option.title),
				uri: uri,
				urlServiceUriTemplate: option.redirect ? urlServiceUriTemplate.attr('href') : null,
				urlServiceOperationName: option.redirect ? urlServiceUriTemplate.attr('title') : null
			});
			
			if (!(form && form.valid)) return;
			
			menu.push({
				text: XRM.localize(option.label),
				onclick: {
					fn: function() { Entity.showCreationDialog(form) }
				}
			});
		});
		
		if (menu.length > 0) {
			new YAHOO.widget.Button({
				container: module,
				type: 'menu',
				label: label,
				title: tooltip,
				menu: menu
			});
		}
	}
	
	ns.renderDeleteButton = function(entityContainer, toolbar, entityUri, entityDisplayName) {
		var entityDeleteUri = $('a.xrm-entity-delete-ref', entityContainer).attr('href');
		
		if (!entityDeleteUri) return;
		
		var module = $('<div />').addClass('xrm-editable-toolbar-module').appendTo(toolbar.body).get(0);
		
		Entity.createDeleteButton(entityContainer, entityDeleteUri, entityDisplayName, module);
	}
	
	ns.renderUpdateButton = function(entityName, entityContainer, toolbar, entityUri, label, tooltip) {
		var module = $('<div />').addClass('xrm-editable-toolbar-module').appendTo(toolbar.body).get(0);
		
		var handler = Entity.handlers[entityName];
			
		if (!handler) return;
		
		var urlServiceUri = $('a.xrm-entity-url-ref', entityContainer);
		
		var form = handler.getForm(entityContainer, {
			title: tooltip,
			uri: entityUri,
			urlServiceUri: urlServiceUri.attr('href'),
			urlServiceOperationName: urlServiceUri.attr('title')
		});
			
		if (!(form && form.valid)) return;
		
		var button = new YAHOO.widget.Button({
			container: module,
			label: label,
			title: tooltip,
			onclick: {
				fn: function() { Entity.showEditDialog(form) }
			}
		});
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Entity.handlers');
	var Entity = XRM.editable.Entity;
	var Handler = Entity.Handler;
	var $ = XRM.jQuery;
	
	var self = ns.adx_webfile = function(entityContainer, toolbar) {
		var entityUri = $('a.xrm-entity-ref', entityContainer).attr('href');

		// We only have functionality to add to the global edit toolbar, so if the entity is not the
		// "current" request entity, or we don't have the entity URI, quit.
		if (!(entityContainer.hasClass('xrm-entity-current') && entityUri)) {
			return;
		}

		self.renderUpdateButton(entityContainer, toolbar, entityUri);
		self.renderDeleteButton(entityContainer, toolbar, entityUri);
		self.renderCreateButton(entityContainer, toolbar, entityUri);
	}
	
	self.formPrototype = {
		uri: null,
		urlServiceUri: null,
		urlServiceUriTemplate: null,
		title: null,
		entityName: 'adx_webfile',
		fields: [
			{ name: 'adx_name', label: 'Name', type: 'text', required: true },
			{ name: 'adx_partialurl', label: 'Partial URL', type: 'text', required: true, slugify: 'adx_name' },
			{ name: 'adx_webfile-attachment', label: 'File', type: 'file', required: true, fileUploadUriTemplate: null, copyFilenameTo: 'adx_name', copyFilenameSlugTo: 'adx_partialurl' },
			{ name: 'adx_displaydate', label: 'Display Date', type: 'datetime', excludeEmptyData: true },
			{ name: 'adx_hiddenfromsitemap', label: 'Hidden from Sitemap', type: 'checkbox' }
		]
	};
	
	self.getForm = function(entityContainer, options) {
		return Handler.getForm(self.formPrototype, entityContainer, options);
	}
	
	self.createOptions = [];
	
	self.renderCreateButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderCreateButton(self.createOptions, entityContainer, toolbar, entityUri, XRM.localize('entity.create.label'), '');
	}
	
	self.renderDeleteButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderDeleteButton(entityContainer, toolbar, entityUri, XRM.localize('adx_webfile.shortname'));
	}
	
	self.renderUpdateButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderUpdateButton('adx_webfile', entityContainer, toolbar, entityUri, XRM.localize('entity.update.label'), XRM.localize('adx_webfile.update.tooltip'));
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Entity.handlers');
	var Entity = XRM.editable.Entity;
	var $ = XRM.jQuery;
	var yuiSkinClass = XRM.yuiSkinClass;
	var JSON = YAHOO.lang.JSON;
	
	var isSortingEnabled = $.isFunction($.fn.sortable);
	
	if (!isSortingEnabled) {
		XRM.log('XRM weblinks sorting disabled. Include jQuery UI with Sortable interaction to enable.', 'warn', 'XRM.editable.Entity.handlers.adx_weblinkset');
	}
	
	var self = ns.adx_weblinkset = function(entityContainer, editToolbar) {
		var entityServiceRef = $('a.xrm-entity-ref', entityContainer);
		var entityServiceUri = entityServiceRef.attr('href');

		if (!entityServiceUri) {
			return XRM.log('Unable to get weblink set service URI. Web links will not be editable.', 'warn', 'editable.Entity.handlers.adx_weblinkset');
		}
		
		var weblinksServiceUri = $('a.xrm-entity-adx_weblinkset_weblink-ref', entityContainer).attr('href');
		var saveWebLinksServiceUri = $('a.xrm-entity-adx_weblinkset_weblink-update-ref', entityContainer).attr('href');
		
		if (!weblinksServiceUri) {
			return XRM.log('Unable to get child weblinks service URI. Web links will not be editable.', 'warn', 'editable.Entity.handlers.adx_weblinkset');
		}
		
		self.addClassIfEmpty(entityContainer);

		entityContainer.editable(weblinksServiceUri, {
			loadSuccess: function(entityData) {
				self.renderEditDialog(entityContainer, editToolbar, weblinksServiceUri, saveWebLinksServiceUri, entityServiceRef.attr('title'), entityData);
			}
		});
	}
	
	self.addClassIfEmpty = function(entityContainer) {
		if (entityContainer.children('ul').children('li').length == 0) {
			entityContainer.addClass('xrm-entity-value-empty');
		}
	}
	
	self.formPrototype = {
		title: null,
		entityName: 'adx_weblink',
		fields: [
			{ name: 'adx_name', label: 'Name', type: 'text', required: true },
			{ name: 'adx_pageid', label: 'Page', type: 'select', uri: null, optionEntityName: 'adx_webpage', optionText: 'adx_name', optionValue: 'adx_webpageid', sortby: 'adx_name' },
			{ name: 'adx_externalurl', label: 'External URL', type: 'text' },
			{ name: 'adx_description', label: 'Description', type: 'html' },
			{ name: 'adx_robotsfollowlink', label: 'Robots follow link', type: 'checkbox', value: true },
			{ name: 'adx_openinnewwindow', label: 'Open in new window', type: 'checkbox' }
		]
	};
	
	self.getWeblinkForm = function(title, weblinkData, entityContainer) {
		weblinkData = weblinkData || {};
		
		var form = $.extend(true, {}, self.formPrototype);
		
		form.title = title;
		form.valid = true;
		
		$.each(form.fields, function(i, field) {
			var propertyName = self.getWeblinkPropertyName(field.name);
			
			if (!propertyName) return;
			
			var propertyData = weblinkData[propertyName];
			
			if (typeof (propertyData) === 'undefined') return;
			
			field.value = propertyData;
		});
		
		$.each(form.fields, function() {
			var field = this;
			
			field.label = XRM.localize(form.entityName + '.' + field.name) || field.label || field.name;
			
			if (field.optionEntityName) {
				var data = $('a.xrm-entity-' + field.optionEntityName + '-ref', entityContainer).attr('href');
				
				if (!data) {
					form.valid = false;
				}
				
				field.uri = data;
			}
			
			if (this.type === 'file') {
				var data = $('a.xrm-uri-template.xrm-entity-' + field.name + '-ref', entityContainer).attr('href');
				
				if (!data) {
					form.valid = false;
				}
				
				field.fileUploadUriTemplate = data;
			}
		});
		
		return form;
	}
	
	self.getWeblinkPropertyName = function(propertySchemaName) {
		return Entity.getPropertyName('adx_weblink', propertySchemaName);
	}
	
	self.renderEditDialog = function(entityContainer, editToolbar, weblinksServiceUri, saveWebLinksServiceUri, entityTitle, entityData) {
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-dialog-weblinkset').appendTo(yuiContainer);

		var webLinkData = $.isArray(entityData.d) ? entityData.d : [];

		function completeEdit(dialog) {
			dialog.cancel();
			yuiContainer.remove();
		}

		var dialog = new YAHOO.widget.Dialog(dialogContainer.get(0), {
			visible: false,
			constraintoviewport: true,
			zindex: XRM.zindex,
			xy: YAHOO.util.Dom.getXY(entityContainer.get(0)),
			buttons: [
				{
					text: XRM.localize('editable.save.label'),
					handler: function() {
						var dialog = this;
						var hideProgressPanel = XRM.ui.showProgressPanelAtXY(XRM.localize('editable.saving'), YAHOO.util.Dom.getXY(dialog.id));
						var weblinksContainer = $('.xrm-editable-weblinks', dialog.body);
						self.saveWebLinks(webLinkData, weblinksContainer, saveWebLinksServiceUri, function (successfulOperations, failedOperations) {
							hideProgressPanel();

							if (failedOperations.length < 1) {
								completeEdit(dialog);
							}
							else {
								XRM.ui.showDataServiceError($.map(failedOperations, function(operation) { return operation.xhr; }));
							}

							// Instead of updating the DOM in-place, just refresh the page.
							document.location = document.location;
						});
					},
					isDefault: true
				},
				{
					text: XRM.localize('editable.cancel.label'),
					handler: function() { completeEdit(this); }
				}
			]
		});

		dialog.setHeader(XRM.localize('editable.label.prefix') + (entityTitle || ''));
		dialog.setBody('<ol class="xrm-editable-weblinks"></ol>');
		
		var displayOrderPropertyName = self.getWeblinkPropertyName('adx_displayorder');

		// Sort weblinks by display order and render them.
		webLinkData.sort(function(a, b) {
			var aOrder = a[displayOrderPropertyName], bOrder = b[displayOrderPropertyName];
			if (aOrder < bOrder) return -1;
			if (aOrder == bOrder) return 0;
			return 1;
		});

		var list = $('.xrm-editable-weblinks', dialog.body);
		
		$.each(webLinkData, function(i, weblink) { self.addWebLinkItem(dialog, list, weblink, entityContainer); });
		
		var testForm = self.getWeblinkForm('', {}, entityContainer);
		
		if (testForm.valid) {
			var weblinkCreationLink = $('<a />').attr('title', XRM.localize('entity.create.adx_weblink.tooltip')).addClass('xrm-add').insertAfter(list).append('<span />');
			
			weblinkCreationLink.click(function() {
				var form = self.getWeblinkForm(XRM.localize('entity.create.adx_weblink.tooltip'), {}, entityContainer);
				
				// Show an entity creation dialog for the web link, but override the default save process of
				// the form, so that instead of POSTing to the service on submission, just grab the JSON for
				// the new web link and stuff it into the DOM for later (when the whole set is saved).
				Entity.showEntityDialog(form, {
					save: function(form, data, options) {
						self.addWebLinkItem(dialog, list, data, entityContainer).hide().show('slow');
															
						if ($.isFunction(options.success)) {
							options.success();
						}
						
						dialog.focus();
					},
					cancel: function() {
						dialog.focus();
					}
				});
			});
		}
		
		if (isSortingEnabled) {
			$('.xrm-editable-weblinks', dialog.body).sortable({ handle: '.xrm-drag-handle', opacity: 0.8 });
		}

		dialog.render();
		dialog.show();

		XRM.ui.registerOverlay(dialog);
		dialog.focus();
	}
	
	self.addWebLinkItem = function(dialog, list, weblink, entityContainer) {
		var item = $('<li />').addClass('xrm-editable-weblink').appendTo(list);
		
		// We'll store any JSON data for weblink updates or creates in this element.
		var weblinkUpdateData = $('<input />').attr('type', 'hidden').addClass('xrm-editable-weblink-data').appendTo(item);
		
		if (isSortingEnabled) {
			$('<a />').attr('title', XRM.localize('editable.sortable.tooltip')).addClass('xrm-drag-handle').appendTo(item);
		}
		else {
			$('<span />').addClass('xrm-drag-disabled').appendTo(item);
		}
		
		$('<a />').attr('title', XRM.localize('entity.delete.adx_weblink.tooltip')).addClass('xrm-delete').appendTo(item).click(function() {
			item.addClass('deleted').hide('slow');
		});
		
		var weblinkName = $('<span />').addClass('name').text(weblink[self.getWeblinkPropertyName('adx_name')]);
		
		var testForm = self.getWeblinkForm(XRM.localize('adx_weblink.update.tooltip'), {}, entityContainer);
		
		if (testForm.valid) {
			$('<a />').attr('title', XRM.localize('adx_weblink.update.tooltip')).addClass('xrm-edit').appendTo(item).click(function() {
				
				var currentWeblinkData = weblink;
				
				try {
					var updateJson = weblinkUpdateData.val();
					
					if (updateJson) {
						currentWeblinkData = JSON.parse(updateJson);
					}
				}
				catch (e) {}
			
				Entity.showEntityDialog(self.getWeblinkForm(XRM.localize('adx_weblink.update.tooltip'), currentWeblinkData, entityContainer), {
					save: function(form, data, options) {
						if (!weblinkUpdateData.hasClass('create')) {
							weblinkUpdateData.addClass('update');
						}
						
						var namePropertyName = self.getWeblinkPropertyName('adx_name');
						
						if (namePropertyName && data[namePropertyName]) {
							weblinkName.text(data[namePropertyName]);
						}
						
						weblinkUpdateData.val(JSON.stringify(data));
						
						if ($.isFunction(options.success)) {
							options.success();
						}
						
						dialog.focus();
					},
					cancel: function() {
						dialog.focus();
					}
				});
				
			});
		}
		
		weblinkName.appendTo(item);
		
		if (weblink.__metadata) {
			$('<a />').attr('href', weblink.__metadata.uri).addClass('xrm-entity-ref').appendTo(item).hide();
			
			var weblinkDeleteUriTemplate = $('a.xrm-uri-template.xrm-entity-adx_weblink-delete-ref', entityContainer).attr('href')
			
			if (weblinkDeleteUriTemplate) {
				var weblinkDeleteUri = XRM.util.expandUriTemplate(weblinkDeleteUriTemplate, weblink);
				
				if (weblinkDeleteUri) {
					$('<a />').attr('href', weblinkDeleteUri).addClass('xrm-entity-delete-ref').appendTo(item).hide();
				}
			}
		}
		else {
			weblinkUpdateData.addClass('create').val(JSON.stringify(weblink));
		}
			
		return item;
	}
	
	self.saveWebLinks = function(webLinkData, weblinksContainer, weblinksServiceUri, completeCallback) {
		// Map our weblink data into an object in for which we can look things up by ID.
		var weblinkMap = {};
		
		$.each(webLinkData, function(i, weblink) { weblinkMap[weblink.__metadata.uri] = weblink });
		
		var operations = [];
		
		// Go through the deleted weblinks (the ones that ever existed to begin with, i.e., weren't
		// just added then deleted in the same edit session), and queue up the delete operation.
		$('.xrm-editable-weblink.deleted', weblinksContainer).each(function(i, item) {
			var weblinkDeleteUri = $('.xrm-entity-delete-ref', item).attr('href');
			
			if (!weblinkDeleteUri) return;
							
			operations.push({ uri: weblinkDeleteUri, method: null });
		});
		
		var displayOrderPropertyName = self.getWeblinkPropertyName('adx_displayorder');
		
		// Go through the non-deleted weblinks, and queue up any update or creation operations.
		$('.xrm-editable-weblink:not(.deleted)', weblinksContainer).each(function(i, item) {
			var weblink = weblinkMap[$('.xrm-entity-ref', item).attr('href')];
			var displayOrder = (i + 1);
			var json = $('.xrm-editable-weblink-data', item).val();
			
			// This is a pre-existing weblink. Construct its update data, and queue the update.
			if (weblink) {
				var data = {}, updated = false;
				
				if (json) {
					try {
						data = JSON.parse(json);
						updated = !!data;
					}
					catch (e) {}
				}
				
				if (weblink[displayOrderPropertyName] != displayOrder) {
					data[displayOrderPropertyName] = displayOrder;
					updated = true;
				}
				
				if (updated) {	
					operations.push({ uri: weblink.__metadata.uri, method: 'MERGE', data: data });
				}
			}
			// This is a newly-added weblink. Construct its data, and queue the create operation.
			else {
				try {
					var data = JSON.parse(json);
					data[displayOrderPropertyName] = displayOrder;
					
					// method is null so that our data APIs don't use an HTTP method override--we just
					// want a normal POST.
					operations.push({ uri: weblinksServiceUri, method: null, data: data });
				}
				catch (e) {
					return;
				}
			}
		});
		
		var successfulOperations = [], failedOperations = [];

		// Signal aggregate save completion, providing both successful and failed operation info.
		function saveComplete() {
			if ($.isFunction(completeCallback)) {
				completeCallback(successfulOperations, failedOperations);
			}
		}

		// Signal that one operation has completed.
		function operationComplete() {
			// If all operations are now completed (successfully or not), signal save completion.
			if ((successfulOperations.length + failedOperations.length) == operations.length) {
				saveComplete();
			}
		}

		// If there are no updates, just signal completion and return.
		if (operations.length < 1) {
			saveComplete();
			return;
		}

		// Post any operations.
		$.each(operations, function(i, operation) {
			XRM.data.postJSON(operation.uri, operation.data, {
				httpMethodOverride: operation.method,
				success: function(data, textStatus) {
					successfulOperations.push({ operation: operation });
					operationComplete();
				},
				error: function(xhr) {
					failedOperations.push({ operation: operation, xhr: xhr });
					operationComplete();
				}
			});
		});
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Entity.handlers');
	var Entity = XRM.editable.Entity;
	var Handler = Entity.Handler;
	var $ = XRM.jQuery;
	
	var self = ns.adx_webpage = function(entityContainer, toolbar) {
		var entityUri = $('a.xrm-entity-ref', entityContainer).attr('href');

		// We only have functionality to add to the global edit toolbar, so if the entity is not the
		// "current" request entity, or we don't have the entity URI, quit.
		if (!(entityContainer.hasClass('xrm-entity-current') && entityUri)) {
			return;
		}
		
		self.renderUpdateButton(entityContainer, toolbar, entityUri);
		self.renderDeleteButton(entityContainer, toolbar, entityUri);
		self.renderCreateButton(entityContainer, toolbar, entityUri);
	}
	
	self.formPrototype = {
		uri: null,
		urlServiceUri: null,
		urlServiceUriTemplate: null,
		title: null,
		entityName: 'adx_webpage',
		fields: [
			{ name: 'adx_name', label: 'Name', type: 'text', required: true },
			{ name: 'adx_partialurl', label: 'Partial URL', type: 'text', required: true, slugify: 'adx_name' },
			{ name: 'adx_pagetemplateid', label: 'Page Template', type: 'select', excludeEmptyData: true, required: true, uri: null, optionEntityName: 'adx_pagetemplate', optionText: 'adx_name', optionValue: 'adx_pagetemplateid', sortby: 'adx_name' },
			{ name: 'adx_displaydate', label: 'Display Date', type: 'datetime', excludeEmptyData: true },
			{ name: 'adx_hiddenfromsitemap', label: 'Hidden from Sitemap', type: 'checkbox' }
		]
	};
	
	self.getForm = function(entityContainer, options) {
		return Handler.getForm(self.formPrototype, entityContainer, options);
	}
	
	self.createOptions = [
		{ entityName: 'adx_webpage', relationship: 'adx_webpage_webpage_Referenced', label: 'entity.create.adx_webpage.label', title: 'entity.create.adx_webpage.tooltip', redirect: true },
		{ entityName: 'adx_webfile', relationship: 'adx_webpage_webfile', label: 'entity.create.adx_webfile.label', title: 'entity.create.adx_webfile.tooltip', redirect: false }
	];
	
	self.renderCreateButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderCreateButton(self.createOptions, entityContainer, toolbar, entityUri, XRM.localize('entity.create.label'), '');
	}
	
	self.renderDeleteButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderDeleteButton(entityContainer, toolbar, entityUri, XRM.localize('adx_webpage.shortname'));
	}
	
	self.renderUpdateButton = function(entityContainer, toolbar, entityUri) {
		Handler.renderUpdateButton('adx_webpage', entityContainer, toolbar, entityUri, XRM.localize('entity.update.label'), XRM.localize('adx_webpage.update.tooltip'));
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable.Entity.handlers');
	var Entity = XRM.editable.Entity;
	var $ = XRM.jQuery;
	var yuiSkinClass = XRM.yuiSkinClass;
	var JSON = YAHOO.lang.JSON;
	
	ns["sitemapchildren"] = function(entityContainer, editToolbar) {
		var entityServiceRef = $('a.xrm-entity-ref-sitemapchildren', entityContainer);
		var entityServiceUri = entityServiceRef.attr('href');
		var entityTitle = entityServiceRef.attr('title');

		if (!entityServiceUri) {
			return XRM.log('Unable to get site map children service URI. Child view will not be editable.', 'warn', 'editable.Entity.handlers.sitemapchildren');
		}
		
		entityContainer.editable(entityServiceUri, {
			loadSuccess: function(entityData) {
				renderEditDialog(entityContainer, entityServiceUri, entityTitle, entityData);
			}
		});
	}
	
	function renderEditDialog(entityContainer, entityServiceUri, entityTitle, entityData) {
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var dialogContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-dialog xrm-editable-dialog-sitemapchildren').appendTo(yuiContainer);

		var childData = $.isArray(entityData.d) ? entityData.d : [];

		function completeEdit(dialog) {
			dialog.cancel();
			yuiContainer.remove();
		}
		
		var list = $('<ol />').addClass('xrm-editable-sitemapchildren');
		
		var dialog = new YAHOO.widget.Dialog(dialogContainer.get(0), {
			visible: false,
			constraintoviewport: true,
			zindex: XRM.zindex,
			xy: YAHOO.util.Dom.getXY(entityContainer.get(0)),
			buttons: [
				{
					text: XRM.localize('editable.save.label'),
					handler: function() {
						var dialog = this;
						var hideProgressPanel = XRM.ui.showProgressPanelAtXY(XRM.localize('editable.saving'), YAHOO.util.Dom.getXY(dialog.id));
						
						saveChildren(childData, list, function(successfulUpdates, failedUpdates) {
							hideProgressPanel();
							completeEdit(dialog);
							document.location = document.location;
						});
					},
					isDefault: true
				},
				{
					text: XRM.localize('editable.cancel.label'),
					handler: function() { completeEdit(this); }
				}
			]
		});

		dialog.setHeader(XRM.localize('sitemapchildren.header.label') + (entityTitle ? (' (' + entityTitle + ')') : ''));
		dialog.setBody(' ');

		list.appendTo(dialog.body);
		
		$.each(childData, function(_, child) {
			var item = $('<li />').addClass('xrm-editable-sitemapchild').appendTo(list);
			$('<a />').attr('title', XRM.localize('editable.sortable.tooltip')).addClass('xrm-drag-handle').appendTo(item);
			$('<span />').addClass('name').html(child.Title || '').appendTo(item);
			
			if (updatableChild(child)) {
				item.addClass('updatable');
				$('<a />').attr('href', child.EntityUri).addClass('xrm-entity-ref').appendTo(item).hide();
			}
		});

		list.sortable({ handle: '.xrm-drag-handle', opacity: 0.8 });

		dialog.render();
		dialog.show();

		XRM.ui.registerOverlay(dialog);
		dialog.focus();
	}
	
	function saveChildren(childData, childContainer, completeCallback) {
		var childMap = {};
		
		$.each(childData, function(_, child) {
			if (updatableChild(child)) {
				childMap[child.EntityUri] = child;
			}
		});
		
		var operations = [];
		
		// Gather the updatable children, and queue updates for their orders, if necessary.
		$('.xrm-editable-sitemapchild.updatable', childContainer).each(function(index, item) {
			var entityUri = $('.xrm-entity-ref', item).attr('href');
			
			if (!entityUri) {
				return;
			}
			
			var child = childMap[entityUri];
			
			if (!child) {
				return;
			}
			
			var displayOrder = (index + 1);
			
			// If the display order has changed, queue the update.
			if (child.DisplayOrder != displayOrder && child.DisplayOrderPropertyName) {
				var data = {};
				data[child.DisplayOrderPropertyName] = displayOrder;
				operations.push({ uri: entityUri, data: data });
			}
		});
		
		var successfulOperations = [], failedOperations = [];

		// Signal aggregate save completion, providing both successful and failed operation info.
		function saveComplete() {
			if ($.isFunction(completeCallback)) {
				completeCallback(successfulOperations, failedOperations);
			}
		}

		// Signal that one operation has completed.
		function operationComplete() {
			// If all operations are now completed (successfully or not), signal save completion.
			if ((successfulOperations.length + failedOperations.length) == operations.length) {
				saveComplete();
			}
		}

		// If there are no updates, just signal completion and return.
		if (operations.length < 1) {
			saveComplete();
			return;
		}

		// Post any operations.
		$.each(operations, function(i, operation) {
			XRM.data.postJSON(operation.uri, operation.data, {
				httpMethodOverride: 'MERGE',
				success: function(data, textStatus) {
					successfulOperations.push({ operation: operation });
					operationComplete();
				},
				error: function(xhr) {
					failedOperations.push({ operation: operation, xhr: xhr });
					operationComplete();
				}
			});
		});
	}
	
	function updatableChild(child) {
		return child && child.EntityUri && child.DisplayOrderPropertyName;
	}
	
});

XRM.onActivate(function() {

	var ns = XRM.namespace('editable');
	var yuiSkinClass = XRM.yuiSkinClass;
	var editableClassRegexp = XRM.editable.editableClassRegexp;
	var Attribute = XRM.editable.Attribute;
	var Entity = XRM.editable.Entity;
	var $ = XRM.jQuery;
	
	$(document).ready(function() {
		XRM.editable.initialize();
	});
	
	ns.initialize = function() {
		var toolbar = ns.toolbar = ns.createToolbar();
		
		ns.initializeToolbar(toolbar);

		Attribute.initialize(toolbar);
		Entity.initialize(toolbar);

		// Only show the global edit toolbar if it contains any functionality.
		if ($('.xrm-editable-toolbar-module', toolbar.body).length > 0) {
		    $('.container-close').attr('role', 'button');
			toolbar.show();
			XRM.ui.registerOverlay(toolbar);
			toolbar.focus();
			$('.container-close', toolbar.element).blur();
		}
	}
	
	ns.initializeToolbar = function(toolbar) {}

	ns.createToolbar = function() {
		var yuiContainer = $('<div />').addClass(yuiSkinClass).appendTo(document.body);
		var toolbarContainer = $('<div />').addClass('xrm-editable-panel xrm-editable-toolbar').appendTo(yuiContainer);

		// Create a draggable control panel, that is anchored to the top right (tr) of the viewport.
		var toolbar = new YAHOO.widget.Panel(toolbarContainer.get(0), {
			close: true,
			draggable: true,
			constraintoviewport: true,
			visible: false,
			context: [document.body, 'tr', 'tr', ['windowResize']],
			zindex: XRM.zindex
		});

		// If this toolbar gets closed, remove the editable controls on XRM entities and attributes.
		toolbar.subscribe('hide', function() {
			$('.xrm-attribute, .xrm-entity').noneditable();
			$('.xrm-attribute-value-empty').removeClass('xrm-attribute-value-empty');
		});

		// YUI doesn't create a body element unless we do this.
		toolbar.setBody(' ');
		toolbar.render();

		return toolbar;
	}
	
});

(function() {

	// This code will validate script dependencies, and only activate XRM inline editing
	// if all dependency checks are satisfied.
	
	var logName = 'XRM.activator';
	
	if (typeof jQuery == "undefined" || !jQuery) {
		XRM.log('jQuery (1.4.2) is required by this libary, and has not been loaded. XRM features will not be activated.', 'warn', logName);
		return;
	}
	
	if (jQuery.fn.jquery !== '1.4.2') {
		XRM.log('This library has been tested with jQuery 1.4.2. You have loaded jQuery ' + jQuery.fn.jquery + '. Features of this libary may not work as designed.', 'warn', logName);
	}
	
	if (typeof YAHOO == "undefined" || !YAHOO) {
		XRM.log('YUI (2.7.0-2.8.0) is required by this libary, and has not been loaded.  XRM features will not be activated.', 'warn', logName);
		return;
	}
	
	XRM.activate(jQuery);
	
})();
