import subprocess
jupyter_args=["/usr/bin/jupyter", "notebook", "--no-browser"]
p=subprocess.call(jupyter_args,shell=True)
