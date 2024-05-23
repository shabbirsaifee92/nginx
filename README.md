# nginx
this represnets a demo application for argo-demo pipeline

On app merge:
  if nodeploy
    - Release the reserved cluster (commit to main, remove annotations)
  else
    - create a new PR on control repo for production-* files for the app
    - Release the reserved cluster (commit to main, remove annotations)

testing
