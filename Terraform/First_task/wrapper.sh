#!/bin/bash
apply_or_destroy () {
  while true;do
    echo "We use the apply(A) or destroy(D)?"
    read -p "" choice_a_or_d
      case $choice_a_or_d in 
        A | a | apply) 
          choice_a_or_d=apply
          break 2;;
        D | d | destroy) 
          choice_a_or_d=destroy
          break 2;;
        *) echo "Try again";;
      esac
  done
  }

dev_or_prod_or_stage () {
  while true;do
    echo "We use the dev(d) or prod(p) or stage(s)?"
    read -p "" choice_d_or_p_or_s
      case $choice_d_or_p_or_s in 
        P | p | prod) 
          terraform workspace select prod
          terraform apply --var-file prod.tfvars 
          break 2;;
        D | d | dev) 
          terraform workspace select dev
          terraform apply --var-file dev.tfvars 
          break 2;;
        S | s | stage) 
          terraform workspace select stage
          terraform apply --var-file stage.tfvars 
          break 2;;
        *) echo "Try again";;
      esac
  done      
}
