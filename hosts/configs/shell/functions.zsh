# create a new git branch
function git_new_branch() {
    from_branch="$(git branch | fzf)"
}

# git choose branch
function git_checkout() {
    branch_name=$(echo $1 | tr -d ' ')
    branches=$(git branch | tr -d ' \t*')

    if [[ ! -z "$branch_name" ]]; then # Check if branch_name is not empty
        if echo "$branches" | grep -Fxq "$branch_name"; then
            # If the branch exists, checkout directly
            git checkout "$branch_name"
        else
            # If the branch does not exist, use fzf with branch_name as initial query
            git branch | tr -d ' \t*' | fzf --query="$branch_name " | xargs git checkout
        fi
    else
        # If branch_name is empty, use fzf without initial query
        git branch | tr -d ' \t*' | fzf | xargs git checkout
    fi
}

# git new branch
function git_new_branch() {
    branch_name=$(echo $1 | tr -d ' ')
    if [ -z "$branch_name" ]; then
        echo "Branch name is required"
        echo "Usage: git_new_branch <branch_name>"
        return
    fi

    from_branch="$(git branch | tr -d ' \t*' | fzf)"
    if [ -z "$from_branch" ]; then
        echo "Canceled"
        return
    fi

    git checkout -b $branch_name $from_branch
}
