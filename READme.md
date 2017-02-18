# LittlePrograms
Just some bunch of scripts and little programs.

So far, I have two actual programs/scripts:

In chronological order, the first I've written is `pills.rb`.
I made it since I couldn't remember whether I already took a pill at any given day.
It also turned out to be a good way to keep track of which ones I need to take for any given day, look up the history, and learn how to use SQLite3 in Ruby.

And then there is the `alarm.rb`.
Literally made it in an hour or two - simple, but works great!
I was having trouble with some of the alarm scripts being unreliable, so I made one myself.
The twist here is that it uses RSS to pull in the latest episode from BBC World podcast (it's awesome - if you haven't, check it out!) and play it at max volume so that I can wake up ~~depressed~~ informed.

Now, the way I'm parsing the XML is *specific* to the one used by the BBC podcast service, and even then, there's no guarantee that they won't change the format (and thus render this program useless)!

Currently, I'm thinking of making some kind of journal, and dabbling on natural language processing and sentiment analysis with Ruby.

Right after I fix the flaming trash that is my main project on my main account...
