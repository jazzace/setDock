# setDock script using dockutil binary

_**Current state of the scripts are:** "the scripts are examples how you can do this"_

```THE SCRIPTS ARE PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
I BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
THE POSSIBILITY OF SUCH DAMAGE.
```
![GitHub](https://img.shields.io/github/license/mvdbent/MSP-example-Scripts)

The scripts are a example how to configures users docks using `docktutil`

Read more here https://appleshare.it/posts/use-dockutil-in-a-script/

**Requirements**
dockutil Version 3.0.0 or higher installed to /usr/local/bin/
_source `dockutil` https://github.com/kcrawford/dockutil/_

## About This Fork
This repo has an enhanced version of setDock-defaultDock that allows you to leverage more dockutil features. It runs as root. If you want to accomplish the same thing but running in the user context, such as with a tool like [Outset](https://github.com/chilcote/outset), use the setDock-defaultDockOutset version of the same script.

### Using setDock-defaultDock[Outset]
Organize the items you wish to have in your Dock into three groups:
1. _alwaysApps:_ Applications that you always want to show up in the Dock, regardless of whether they are present or not (a ? will be displayed if the item is not present on the system);
2. _alwaysOthers:_ Items (folders, files) that you always want to show up in the right side (or bottom end) of the Dock;
3. _optionalItems:_ Apps or Others that you would like to include only if present on the system.

Those three arrays are located at the top of the script. Replace the paths to the apps/items with those you require using the syntax shown. The comments in the code provide additional tips.

You may add any of the options available in dockutil to the items in `alwaysOthers` and `optionalItems`. You do this by specifying the option(s) in the partner array:
- optionsOthers (for alwaysOthers)
- optionsOptional (for optionalItems)

For example, you always want Applications and the user’s Downloads folder in the Dock. When the user clicks on Applications in the Dock, you want the Applications folder to display as a grid sorted by name, but when the user’s Downloads folder is clicked, you want it displayed as a list sorted by date added. This is how you would set up the arrays to do that:
```
alwaysOthers=(
"/Applications"
"~/Downloads"
)

optionsOthers=(
"--view grid --display folder --sort name"
"--view list --display folder --sort dateadded"
)
```

The optionalItems/optionsOptional array pairing works in the same way. You can use any dockutil arguments, so options like `--replacing`, `--before`, and `--after` are common here. Because items in this pair of arrays are only added if they exist, it is very useful for things like System Preferences (macOS Monterey and earlier) versus System Settings (macOS Ventura) or if you only have pro apps on some computers (e.g., add iMovie in the `alwaysApps` and then have Final Cut Pro `--replacing iMovie` in this section).

Note that dockutil may only see items from alwaysApps for use with relative placement or replacement. If you simply want to add the optional item to the end of the appropriate part of the Dock and not specify any options, you may use an empty string (`""`) for that item’s options.

If the paired arrays are unmatched in length, this fact will be logged but execution will proceed. Any item in alwaysOthers or optionalItems that does not have a matching item will proceed as if no dockutil options were specified.