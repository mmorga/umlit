# umlit file formats

# Common Structure & Syntax

Curly braces indication optional parameters, square brackets indicate required parameters.

Optional line to make file runnable

    #!/usr/bin/env umlit {options}

Comments to the end of the line

    # Comments

Setting the diagram type (must be only one of the following)

    activity {diagram title}
    deployment {diagram title}
    sequence {diagram title}
    component {diagram title}

Setting the theme of the diagram

		theme [theme name]

Setting the CSS style file for inclusion

		style [/path/to/css/file]

Setting the output file explicitly

		output [/path/to/output/file]

Nodes are named by a collection of lower and upper case letters, numbers, and underscores.

		[a-zA-Z0-9_]+

Connect one node (of one sort to another)
		
		Sensor->EventAPI

Label the connecting line

		Sensor->EventAPI: Event POSTed to REST API

Packages (except for sequence)

	package [name] do
		...
	end

Node settings

		nodeName [settings]

Settings are comma separated and can be:

		id="dom-id"
		label="Nicer Label"

		component {name} do
			id "dom-id"
			label "Nicer Label"

			node1
			node2
			node3
			node4
		end

		interface {name} do
			...
		end

		database {name} do
		end

		portal {name} do
		end


# Sequence Diagram Syntax

Nodes in a sequence diagram refer to the participants in the Sequence

Activating or Deactivating a participant is done via activate and deactivate keywords:

		Sensor->EventAPI: Event POSTed to REST API
		activate EventAPI
		EventAPI->Riak: Save Event 
		EventAPI->Sensor: Return 201 created message with URI of Event
		deactivate EventAPI


TODO: color, fillcolor

